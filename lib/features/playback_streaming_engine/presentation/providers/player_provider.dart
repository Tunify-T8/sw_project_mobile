import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/playback_event.dart';
import '../../domain/entities/playback_queue.dart';
import '../../domain/entities/playback_status.dart';
import '../../domain/entities/stream_url.dart';
import '../../domain/entities/track_playback_bundle.dart';
import '../../domain/usecases/build_playback_queue_usecase.dart';
import '../../domain/usecases/get_playback_bundle_usecase.dart';
import '../../domain/usecases/report_playback_event_usecase.dart';
import '../../domain/usecases/request_stream_url_usecase.dart';
import 'player_repository_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PlayerState {
  const PlayerState({
    this.bundle,
    this.streamUrl,
    this.queue,
    this.isPlaying = false,
    this.positionSeconds = 0,
    this.isMuted = false,
    this.volume = 1.0,
  });

  final TrackPlaybackBundle? bundle;
  final StreamUrl? streamUrl;
  final PlaybackQueue? queue;
  final bool isPlaying;
  final int positionSeconds;
  final bool isMuted;
  final double volume;

  bool get hasTrack => bundle != null;
  bool get canPlay =>
      bundle != null &&
      bundle!.playability.status != PlaybackStatus.blocked;

  PlayerState copyWith({
    TrackPlaybackBundle? bundle,
    StreamUrl? streamUrl,
    PlaybackQueue? queue,
    bool? isPlaying,
    int? positionSeconds,
    bool? isMuted,
    double? volume,
  }) {
    return PlayerState(
      bundle: bundle ?? this.bundle,
      streamUrl: streamUrl ?? this.streamUrl,
      queue: queue ?? this.queue,
      isPlaying: isPlaying ?? this.isPlaying,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      isMuted: isMuted ?? this.isMuted,
      volume: volume ?? this.volume,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class PlayerNotifier extends AsyncNotifier<PlayerState> {
  late GetPlaybackBundleUsecase _getBundle;
  late RequestStreamUrlUsecase _requestStream;
  late ReportPlaybackEventUsecase _reportEvent;
  late BuildPlaybackQueueUsecase _buildQueue;

  Timer? _progressTimer;

  /// Safe getter — works across all Riverpod 2.x versions.
  /// [asData?.value] is equivalent to [valueOrNull] from Riverpod 2.4+.
  PlayerState? get _current => state.asData?.value;

  @override
  Future<PlayerState> build() async {
    final repo = ref.watch(playerRepositoryProvider);
    _getBundle = GetPlaybackBundleUsecase(repo);
    _requestStream = RequestStreamUrlUsecase(repo);
    _reportEvent = ReportPlaybackEventUsecase(repo);
    _buildQueue = BuildPlaybackQueueUsecase(repo);

    ref.onDispose(() {
      _progressTimer?.cancel();
    });

    return const PlayerState();
  }

  // -------------------------------------------------------------------------
  // Load a track into the player
  // -------------------------------------------------------------------------

  Future<void> loadTrack(String trackId, {String? privateToken}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final bundle = await _getBundle(trackId, privateToken: privateToken);

      // If blocked — return state without a stream URL, UI shows blocked msg
      if (bundle.playability.isBlocked) {
        return PlayerState(bundle: bundle);
      }

      final streamUrl = await _requestStream(trackId);
      return PlayerState(bundle: bundle, streamUrl: streamUrl);
    });
  }

  // -------------------------------------------------------------------------
  // Play
  // -------------------------------------------------------------------------

  Future<void> play() async {
    final current = _current;
    if (current == null || !current.canPlay) return;

    // Refresh stream URL if it has expired
    StreamUrl? streamUrl = current.streamUrl;
    if (streamUrl == null) {
      streamUrl = await _requestStream(current.bundle!.trackId);
    }

    state = AsyncData(
      current.copyWith(isPlaying: true, streamUrl: streamUrl),
    );

    await _reportEvent(PlaybackEvent(
      trackId: current.bundle!.trackId,
      action: PlaybackAction.play,
      positionSeconds: current.positionSeconds,
    ));

    _startProgressTimer();
  }

  // -------------------------------------------------------------------------
  // Pause
  // -------------------------------------------------------------------------

  Future<void> pause() async {
    final current = _current;
    if (current == null || !current.isPlaying) return;

    _progressTimer?.cancel();
    state = AsyncData(current.copyWith(isPlaying: false));

    await _reportEvent(PlaybackEvent(
      trackId: current.bundle!.trackId,
      action: PlaybackAction.pause,
      positionSeconds: current.positionSeconds,
    ));
  }

  // -------------------------------------------------------------------------
  // Seek
  // -------------------------------------------------------------------------

  Future<void> seek(int positionSeconds) async {
    final current = _current;
    if (current == null) return;

    state = AsyncData(current.copyWith(positionSeconds: positionSeconds));
  }

  // -------------------------------------------------------------------------
  // Toggle mute
  // -------------------------------------------------------------------------

  void toggleMute() {
    final current = _current;
    if (current == null) return;
    state = AsyncData(current.copyWith(isMuted: !current.isMuted));
  }

  // -------------------------------------------------------------------------
  // Set volume (0.0 – 1.0)
  // -------------------------------------------------------------------------

  void setVolume(double volume) {
    final current = _current;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(volume: volume.clamp(0.0, 1.0)),
    );
  }

  // -------------------------------------------------------------------------
  // Next / Previous (requires a loaded queue)
  // -------------------------------------------------------------------------

  Future<void> next() async {
    final current = _current;
    if (current?.queue == null) return;

    final queue = current!.queue!;
    final nextIndex = queue.currentIndex + 1;

    if (nextIndex >= queue.trackIds.length) {
      if (queue.repeat == RepeatMode.all) {
        await _jumpToIndex(0, queue);
      }
      return;
    }
    await _jumpToIndex(nextIndex, queue);
  }

  Future<void> previous() async {
    final current = _current;
    if (current?.queue == null) return;

    final queue = current!.queue!;
    // If more than 3 seconds in — restart current track
    if (current.positionSeconds > 3) {
      await seek(0);
      return;
    }

    final prevIndex = queue.currentIndex - 1;
    if (prevIndex < 0) return;
    await _jumpToIndex(prevIndex, queue);
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  Future<void> _jumpToIndex(int index, PlaybackQueue queue) async {
    final newQueue = queue.copyWith(currentIndex: index);
    final trackId = queue.trackIds[index];

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final bundle = await _getBundle(trackId);
      final streamUrl = bundle.playability.isBlocked
          ? null
          : await _requestStream(trackId);
      return PlayerState(
        bundle: bundle,
        streamUrl: streamUrl,
        queue: newQueue,
        isPlaying: true,
      );
    });

    // asData?.value is safe even if guard produced an AsyncError
    if (state.asData?.value?.isPlaying == true) {
      await _reportEvent(PlaybackEvent(
        trackId: trackId,
        action: PlaybackAction.play,
        positionSeconds: 0,
      ));
      _startProgressTimer();
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async {
        final current = _current;
        if (current == null || !current.isPlaying) {
          _progressTimer?.cancel();
          return;
        }
        final newPosition = current.positionSeconds + 10;
        state = AsyncData(current.copyWith(positionSeconds: newPosition));

        await _reportEvent(PlaybackEvent(
          trackId: current.bundle!.trackId,
          action: PlaybackAction.progress,
          positionSeconds: newPosition,
        ));
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final playerProvider =
    AsyncNotifierProvider<PlayerNotifier, PlayerState>(PlayerNotifier.new);