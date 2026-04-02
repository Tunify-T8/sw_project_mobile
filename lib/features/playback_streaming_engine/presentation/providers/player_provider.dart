import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

import '../../../../core/storage/storage_keys.dart';
import '../../../audio_upload_and_management/data/services/global_track_store.dart';
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
import '../../domain/usecases/build_playback_queue_usecase.dart';
import '../../domain/usecases/get_playback_bundle_usecase.dart';
import '../../domain/usecases/report_playback_event_usecase.dart';
import '../../domain/usecases/request_stream_url_usecase.dart';
import 'listening_history_provider.dart';
import 'player_backend_mode_provider.dart';
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
  late GetPlaybackBundleUsecase _getBundle;
  late RequestStreamUrlUsecase _requestStream;
  late ReportPlaybackEventUsecase _reportEvent;
  late BuildPlaybackQueueUsecase _buildQueue;

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
  DateTime? _lastSessionPersistAt;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  PlayerState? get _current => state.asData?.value;

  void _setPlayerState(PlayerState nextState) {
    state = AsyncData(nextState);
  }

  Future<void> _trackHistoryPlayed(
    HistoryTrack historyTrack, {
    required bool needsBackendSync,
  }) {
    return ref
        .read(listeningHistoryProvider.notifier)
        .trackPlayed(historyTrack, needsBackendSync: needsBackendSync);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _handleLifecycleStateChanged(state);
  }

  @override
  Future<PlayerState> build() async {
    final repo = ref.watch(playerRepositoryProvider);
    _getBundle = GetPlaybackBundleUsecase(repo);
    _requestStream = RequestStreamUrlUsecase(repo);
    _reportEvent = ReportPlaybackEventUsecase(repo);
    _buildQueue = BuildPlaybackQueueUsecase(repo);

    _attachPlayerBindings();
    _attachLifecycleObserver();

    ref.onDispose(() async {
      _progressReportTimer?.cancel();
      await _persistCurrentSession(force: true);
      _detachLifecycleObserver();
      await _positionSubscription?.cancel();
      await _durationSubscription?.cancel();
      await _playerStateSubscription?.cancel();
      await _audioPlayer.dispose();
    });

    return _restorePersistedSession();
  }
}

final playerProvider = AsyncNotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);
