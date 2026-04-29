import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

import '../../../../core/storage/safe_secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../domain/entities/history_track.dart';
import '../../domain/entities/playback_event.dart';
import '../../domain/entities/playback_context_request.dart';
import '../../domain/entities/playback_queue.dart';
import '../../domain/entities/playback_status.dart';
import '../../domain/entities/player_seed_track.dart';
import '../../domain/entities/playability_info.dart';
import '../../domain/entities/preview_info.dart';
import '../../domain/entities/stream_url.dart';
import '../../domain/entities/track_artist_summary.dart';
import '../../domain/entities/track_playback_bundle.dart';
import '../../domain/entities/track_engagement.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/usecases/build_playback_queue_usecase.dart';
import '../../domain/usecases/get_playback_bundle_usecase.dart';
import '../../domain/usecases/report_playback_event_usecase.dart';
import '../../domain/usecases/report_track_completed_usecase.dart';
import '../../domain/usecases/request_stream_url_usecase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../audio_upload_and_management/data/services/audio_cache_service.dart';
import '../../data/api/user_tracks_api.dart';
import 'listening_history_provider.dart';
import 'player_backend_mode_provider.dart';
// Provides userTracksApiProvider used by enrichQueueWithArtistTracks
// in player_provider_queue.dart to fetch the playing artist's catalog.
import 'player_dependencies_provider.dart';
import 'player_local_file_guard.dart';
import 'player_repository_provider.dart';

part 'player_provider_state.dart';
part 'player_provider_loading.dart';
part 'player_provider_controls.dart';
part 'player_provider_queue.dart';
part 'player_provider_sources.dart';
part 'player_provider_bindings.dart';
part 'player_provider_persistence.dart';

class PlayerNotifier extends AsyncNotifier<PlayerState>
    with WidgetsBindingObserver {
  late PlayerRepository _repository;
  late GetPlaybackBundleUsecase _getBundle;
  late RequestStreamUrlUsecase _requestStream;
  late ReportPlaybackEventUsecase _reportEvent;
  late ReportTrackCompletedUsecase _reportTrackCompleted;
  late BuildPlaybackQueueUsecase _buildQueue;
  late AudioCacheService _audioCache;

  /// Tracks which track IDs have already had a 90 % completion reported this
  /// session so we never double-report.
  final Set<String> _completedTrackIds = {};

  /// Set to the current track's ID when play() is called. Cleared once the
  /// position stream confirms ≥ 2 seconds of real playback have elapsed, at
  /// which point _notifyHistoryPlayed() is fired. Cleared immediately when a
  /// new track is loaded so the old track is never mistakenly counted.
  String? _pendingHistoryTrackId;

  final just_audio.AudioPlayer _audioPlayer = just_audio.AudioPlayer();

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<just_audio.PlayerState>? _playerStateSubscription;
  Timer? _progressReportTimer;

  String? _loadedTrackId;
  String? _loadedSourceKey;
  bool _bindingsAttached = false;
  bool _lifecycleObserverAttached = false;
  bool _handlingCompletion = false;
  bool _handlingPreviewStop = false;
  bool _isManualSeeking = false;
  bool _isDisposed = false;
  bool _isLoadingTrack = false;
  bool _isTransportBusy = false;
  DateTime? _lastSessionPersistAt;
  PlayerState? _lastKnownState;

  PlayerState? get _current => _lastKnownState;

  void _setPlayerState(PlayerState nextState) {
    _lastKnownState = nextState;
    if (_isDisposed || !ref.mounted) {
      return;
    }
    state = AsyncData(nextState);
  }

  void _setAsyncState(AsyncValue<PlayerState> nextState) {
    if (nextState case AsyncData<PlayerState>(:final value)) {
      _lastKnownState = value;
    }
    if (_isDisposed || !ref.mounted) {
      return;
    }
    state = nextState;
  }

  Future<void> _trackHistoryPlayed(
    HistoryTrack historyTrack, {
    required bool needsBackendSync,
  }) {
    return ref
        .read(listeningHistoryProvider.notifier)
        .trackPlayed(historyTrack, needsBackendSync: needsBackendSync);
  }

  /// Saves the current playback position into the local Listening History store.
  ///
  /// This is intentionally local-first. The backend does not need a progress
  /// endpoint for this to work. We call it from the position stream, lifecycle
  /// events, pause, and seek so Recently Played/History can resume from the last
  /// known second.
  void _rememberCurrentHistoryPosition(
    PlayerState playerState, {
    bool force = false,
  }) {
    if (_isDisposed || !ref.mounted) return;

    final bundle = playerState.bundle;
    if (bundle == null) return;

    final durationSeconds = playerState.visualDurationSeconds > 0
        ? playerState.visualDurationSeconds
        : bundle.durationSeconds;

    var positionSeconds = playerState.positionSeconds.round();
    if (positionSeconds < 0) {
      positionSeconds = 0;
    }

    // If the track has a known duration, never persist a value past the end.
    if (durationSeconds > 0 && positionSeconds > durationSeconds) {
      positionSeconds = durationSeconds;
    }

    // Avoid rewriting history too aggressively while the position stream fires.
    // Force is used for lifecycle/pause paths where we want the latest value now.
    if (!force && positionSeconds <= 0) return;

    try {
      unawaited(
        ref
            .read(listeningHistoryProvider.notifier)
            .updateTrackProgress(bundle.trackId, positionSeconds),
      );
    } catch (_) {
      // Local history is best-effort. Playback must never crash because the
      // history cache could not be updated.
    }
  }

  /// Sends a playback event without ever allowing reporting failures to break
  /// the audio player. Some backend builds currently no-op these events, and
  /// offline mode may fail network calls, so this must stay safe.
  Future<void> _safeReportEvent(PlaybackEvent event) async {
    try {
      await _reportEvent(event);
    } catch (_) {
      // Reporting is best-effort only.
    }
  }

  /// Reports a 90% completed play safely. If the device is offline, the play is
  /// queued locally through the repository fallback when available.
  Future<void> _safeReportTrackCompleted(String trackId) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity.any(
        (result) => result != ConnectivityResult.none,
      );

      if (isOnline) {
        await _reportTrackCompleted(trackId);
        return;
      }

      await _repository.markOfflinePlayCompleted(trackId);
    } catch (_) {
      // Completion reporting is best-effort only.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _handleLifecycleStateChanged(state);
  }

  @override
  Future<PlayerState> build() async {
    final repo = ref.watch(playerRepositoryProvider);
    _repository = repo;
    _getBundle = GetPlaybackBundleUsecase(repo);
    _requestStream = RequestStreamUrlUsecase(repo);
    _reportEvent = ReportPlaybackEventUsecase(repo);
    _reportTrackCompleted = ReportTrackCompletedUsecase(repo);
    _buildQueue = BuildPlaybackQueueUsecase(repo);
    _audioCache = AudioCacheService(ref.read(globalTrackStoreProvider));

    _attachPlayerBindings();
    _attachLifecycleObserver();

    ref.onDispose(() {
      _isDisposed = true;
      final current = _lastKnownState;
      final positionSubscription = _positionSubscription;
      final durationSubscription = _durationSubscription;
      final playerStateSubscription = _playerStateSubscription;

      _progressReportTimer?.cancel();
      _detachLifecycleObserver();

      unawaited(() async {
        await _persistCurrentSession(playerState: current, force: true);
        await positionSubscription?.cancel();
        await durationSubscription?.cancel();
        await playerStateSubscription?.cancel();
        await _audioPlayer.dispose();
      }());
    });

    final restored = await _restorePersistedSession();
    _lastKnownState = restored;
    return restored;
  }
}

final playerProvider = AsyncNotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);
