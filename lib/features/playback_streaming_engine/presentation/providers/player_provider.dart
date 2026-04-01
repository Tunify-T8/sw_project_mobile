import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as just_audio;

import '../../domain/entities/playback_event.dart';
import '../../domain/entities/playback_context_request.dart';
import '../../domain/entities/playback_queue.dart';
import '../../domain/entities/playback_status.dart';
import '../../domain/entities/player_seed_track.dart';
import '../../domain/entities/stream_url.dart';
import '../../domain/entities/track_playback_bundle.dart';
import '../../domain/usecases/build_playback_queue_usecase.dart';
import '../../domain/usecases/get_playback_bundle_usecase.dart';
import '../../domain/usecases/report_playback_event_usecase.dart';
import '../../domain/usecases/request_stream_url_usecase.dart';
import 'player_backend_mode_provider.dart';
import 'player_repository_provider.dart';

const Object _sentinel = Object();

class PlayerState {
  const PlayerState({
    this.bundle,
    this.streamUrl,
    this.queue,
    this.isPlaying = false,
    this.positionSeconds = 0,
    this.isMuted = false,
    this.volume = 1.0,
    this.isBuffering = false,
    this.streamExpiresAt,
    this.localFilePath,
  });

  final TrackPlaybackBundle? bundle;
  final StreamUrl? streamUrl;
  final PlaybackQueue? queue;
  final bool isPlaying;
  final double positionSeconds;
  final bool isMuted;
  final double volume;
  final bool isBuffering;
  final DateTime? streamExpiresAt;
  final String? localFilePath;

  bool get hasTrack => bundle != null;

  bool get canPlay =>
      bundle != null && bundle!.playability.status != PlaybackStatus.blocked;

  bool get isPreviewOnly =>
      bundle != null && bundle!.playability.status == PlaybackStatus.preview;

  int get previewStartSeconds => bundle?.preview.previewStartSeconds ?? 0;

  int get previewEndSeconds {
    final activeBundle = bundle;
    if (activeBundle == null) return 0;

    if (!activeBundle.playability.isPreviewOnly ||
        !activeBundle.preview.enabled) {
      return activeBundle.durationSeconds;
    }

    return activeBundle.preview.previewStartSeconds +
        activeBundle.preview.previewDurationSeconds;
  }

  int get effectiveDurationSeconds {
    final activeBundle = bundle;
    if (activeBundle == null) return 0;

    return activeBundle.playability.isPreviewOnly &&
            activeBundle.preview.enabled
        ? activeBundle.preview.previewDurationSeconds
        : activeBundle.durationSeconds;
  }

  PlayerState copyWith({
    Object? bundle = _sentinel,
    Object? streamUrl = _sentinel,
    Object? queue = _sentinel,
    bool? isPlaying,
    double? positionSeconds,
    bool? isMuted,
    double? volume,
    bool? isBuffering,
    Object? streamExpiresAt = _sentinel,
    Object? localFilePath = _sentinel,
  }) {
    return PlayerState(
      bundle: identical(bundle, _sentinel)
          ? this.bundle
          : bundle as TrackPlaybackBundle?,
      streamUrl: identical(streamUrl, _sentinel)
          ? this.streamUrl
          : streamUrl as StreamUrl?,
      queue: identical(queue, _sentinel) ? this.queue : queue as PlaybackQueue?,
      isPlaying: isPlaying ?? this.isPlaying,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      isMuted: isMuted ?? this.isMuted,
      volume: volume ?? this.volume,
      isBuffering: isBuffering ?? this.isBuffering,
      streamExpiresAt: identical(streamExpiresAt, _sentinel)
          ? this.streamExpiresAt
          : streamExpiresAt as DateTime?,
      localFilePath: identical(localFilePath, _sentinel)
          ? this.localFilePath
          : localFilePath as String?,
    );
  }
}

class _ResolvedPlaybackSource {
  const _ResolvedPlaybackSource({
    this.streamUrl,
    this.streamExpiresAt,
    this.localFilePath,
  });

  final StreamUrl? streamUrl;
  final DateTime? streamExpiresAt;
  final String? localFilePath;

  String? get sourceKey => localFilePath ?? streamUrl?.url;
}

class PlayerNotifier extends AsyncNotifier<PlayerState> {
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
  bool _handlingCompletion = false;
  bool _handlingPreviewStop = false;
  bool _isManualSeeking = false;

  PlayerState? get _current => state.asData?.value;

  @override
  Future<PlayerState> build() async {
    final repo = ref.watch(playerRepositoryProvider);
    _getBundle = GetPlaybackBundleUsecase(repo);
    _requestStream = RequestStreamUrlUsecase(repo);
    _reportEvent = ReportPlaybackEventUsecase(repo);
    _buildQueue = BuildPlaybackQueueUsecase(repo);

    _attachPlayerBindings();

    ref.onDispose(() async {
      _progressReportTimer?.cancel();
      await _positionSubscription?.cancel();
      await _durationSubscription?.cancel();
      await _playerStateSubscription?.cancel();
      await _audioPlayer.dispose();
    });

    return const PlayerState();
  }

  Future<void> loadTrack(
    String trackId, {
    String? privateToken,
    PlaybackQueue? queue,
    bool autoPlay = false,
    PlayerSeedTrack? seedTrack,
  }) async {
    final previous = _current;

    _progressReportTimer?.cancel();
    await _audioPlayer.stop();

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final bundle = await _resolveBundle(
        trackId,
        privateToken: privateToken,
        seedTrack: seedTrack,
      );

      final source = await _resolvePlaybackSource(
        trackId,
        seedTrack: seedTrack,
      );

      final initialPosition = _initialPositionFor(bundle).toDouble();

      final nextState = PlayerState(
        bundle: bundle,
        streamUrl: source.streamUrl,
        streamExpiresAt: source.streamExpiresAt,
        localFilePath: source.localFilePath,
        queue: queue,
        isPlaying: false,
        positionSeconds: initialPosition,
        isMuted: previous?.isMuted ?? false,
        volume: previous?.volume ?? 1.0,
        isBuffering: false,
      );

      await _prepareAudioSource(nextState, force: true);
      await _applyVolume(nextState);

      if (initialPosition > 0) {
        await _audioPlayer.seek(
          Duration(milliseconds: (initialPosition * 1000).round()),
        );
      }

      return nextState;
    });

    if (autoPlay && state.asData?.value != null) {
      await play();
    }
  }

  Future<void> loadTrackWithQueue({
    required String trackId,
    required List<String> trackIds,
    int currentIndex = 0,
    String? privateToken,
    bool autoPlay = true,
    RepeatMode repeat = RepeatMode.none,
    PlayerSeedTrack? seedTrack,
  }) {
    return loadTrack(
      trackId,
      privateToken: privateToken,
      autoPlay: autoPlay,
      seedTrack: seedTrack,
      queue: PlaybackQueue(
        trackIds: trackIds,
        currentIndex: currentIndex,
        shuffle: false,
        repeat: repeat,
      ),
    );
  }

  Future<void> play() async {
    final current = _current;
    if (current == null || !current.canPlay) return;

    var preparedState = await _ensureFreshPlaybackSource(current);
    if (preparedState == null) return;

    final restartPosition =
        preparedState.positionSeconds >= preparedState.previewEndSeconds
            ? _initialPositionFor(preparedState.bundle!).toDouble()
            : null;

    if (restartPosition != null) {
      await _audioPlayer.seek(
        Duration(milliseconds: (restartPosition * 1000).round()),
      );
      preparedState = preparedState.copyWith(
        positionSeconds: restartPosition,
      );
      state = AsyncData(preparedState);
    }

    await _applyVolume(preparedState);
    await _audioPlayer.play();

    state = AsyncData(
      preparedState.copyWith(
        isPlaying: true,
        isBuffering: false,
      ),
    );

    await _safeReportEvent(
      PlaybackEvent(
        trackId: preparedState.bundle!.trackId,
        action: PlaybackAction.play,
        positionSeconds: preparedState.positionSeconds.round(),
      ),
    );

    _startProgressReporting();
  }

  Future<void> pause() async {
    final current = _current;
    if (current == null) return;

    _progressReportTimer?.cancel();
    await _audioPlayer.pause();

    final pausedPosition = _audioPlayer.position.inMilliseconds / 1000.0;

    state = AsyncData(
      current.copyWith(
        isPlaying: false,
        isBuffering: false,
        positionSeconds: _clampPosition(current.bundle!, pausedPosition),
      ),
    );

    await _safeReportEvent(
      PlaybackEvent(
        trackId: current.bundle!.trackId,
        action: PlaybackAction.pause,
        positionSeconds:
            _clampPosition(current.bundle!, pausedPosition).round(),
      ),
    );
  }

  Future<void> seek(num positionSeconds) async {
    final current = _current;
    if (current == null || current.bundle == null) return;

    final clamped = _clampPosition(
      current.bundle!,
      positionSeconds.toDouble(),
    );

    _isManualSeeking = true;

    await _audioPlayer.seek(
      Duration(milliseconds: (clamped * 1000).round()),
    );

    state = AsyncData(
      current.copyWith(
        positionSeconds: clamped,
        isBuffering: false,
      ),
    );

    await _safeReportEvent(
      PlaybackEvent(
        trackId: current.bundle!.trackId,
        action: PlaybackAction.progress,
        positionSeconds: clamped.round(),
      ),
    );

    Future<void>.delayed(const Duration(milliseconds: 180), () {
      _isManualSeeking = false;
    });
  }

  void toggleMute() {
    final current = _current;
    if (current == null) return;

    final next = current.copyWith(isMuted: !current.isMuted);
    state = AsyncData(next);
    unawaited(_applyVolume(next));
  }

  void setVolume(double volume) {
    final current = _current;
    if (current == null) return;

    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    final next = current.copyWith(volume: safeVolume);
    state = AsyncData(next);
    unawaited(_applyVolume(next));
  }

  Future<void> next() async {
    final current = _current;
    if (current?.queue == null) return;

    final queue = current!.queue!;
    if (queue.trackIds.length <= 1) return;

    final nextIndex = queue.currentIndex + 1;

    if (nextIndex >= queue.trackIds.length) {
      if (queue.repeat == RepeatMode.all) {
        await _jumpToIndex(0, queue, autoPlay: current.isPlaying);
      }
      return;
    }

    await _jumpToIndex(nextIndex, queue, autoPlay: current.isPlaying);
  }

  Future<void> previous() async {
    final current = _current;
    if (current?.queue == null) return;

    final queue = current!.queue!;
    if (queue.trackIds.length <= 1) return;

    final previousIndex = queue.currentIndex - 1;

    if (previousIndex < 0) {
      if (queue.repeat == RepeatMode.all) {
        await _jumpToIndex(
          queue.trackIds.length - 1,
          queue,
          autoPlay: current.isPlaying,
        );
      }
      return;
    }

    await _jumpToIndex(previousIndex, queue, autoPlay: current.isPlaying);
  }

  Future<void> jumpToQueueIndex(int index) async {
    final current = _current;
    if (current?.queue == null) return;

    final queue = current!.queue!;
    if (index < 0 || index >= queue.trackIds.length) return;

    await _jumpToIndex(index, queue, autoPlay: current.isPlaying);
  }

  Future<void> buildAndLoadQueue({
    required PlaybackContextType contextType,
    required String contextId,
    required String startTrackId,
    bool shuffle = false,
    RepeatMode repeat = RepeatMode.none,
    String? privateToken,
    bool autoPlay = true,
  }) async {
    final queue = await _buildQueue(
      PlaybackContextRequest(
        contextType: contextType,
        contextId: contextId,
        startTrackId: startTrackId,
        shuffle: shuffle,
        repeat: repeat,
      ),
    );

    await loadTrack(
      startTrackId,
      privateToken: privateToken,
      queue: queue,
      autoPlay: autoPlay,
    );
  }

  Future<void> _jumpToIndex(
    int index,
    PlaybackQueue queue, {
    required bool autoPlay,
  }) async {
    final nextQueue = queue.copyWith(currentIndex: index);

    await loadTrack(
      queue.trackIds[index],
      queue: nextQueue,
      autoPlay: autoPlay,
    );
  }

  Future<TrackPlaybackBundle> _resolveBundle(
    String trackId, {
    String? privateToken,
    PlayerSeedTrack? seedTrack,
  }) async {
    final mode = ref.read(playerBackendModeProvider);

    if (mode == PlayerBackendMode.mock && seedTrack != null) {
      return seedTrack.toPlaybackBundle();
    }

    try {
      return await _getBundle(trackId, privateToken: privateToken);
    } catch (_) {
      if (mode == PlayerBackendMode.mock && seedTrack != null) {
        return seedTrack.toPlaybackBundle();
      }
      rethrow;
    }
  }

  Future<_ResolvedPlaybackSource> _resolvePlaybackSource(
    String trackId, {
    PlayerSeedTrack? seedTrack,
  }) async {
    final mode = ref.read(playerBackendModeProvider);

    if (mode == PlayerBackendMode.mock && seedTrack != null) {
      final directStream = seedTrack.toDirectStreamUrl();

      return _ResolvedPlaybackSource(
        streamUrl: directStream,
        streamExpiresAt: directStream == null
            ? null
            : DateTime.now().add(
                Duration(seconds: directStream.expiresInSeconds),
              ),
        localFilePath: seedTrack.localFilePath,
      );
    }

    final streamUrl = await _requestStream(trackId);

    return _ResolvedPlaybackSource(
      streamUrl: streamUrl,
      streamExpiresAt: DateTime.now().add(
        Duration(seconds: streamUrl.expiresInSeconds),
      ),
      localFilePath: null,
    );
  }

  Future<PlayerState?> _ensureFreshPlaybackSource(PlayerState current) async {
    if (current.bundle == null) return null;

    final expiresAt = current.streamExpiresAt;
    final mustRefresh = current.localFilePath == null &&
        (current.streamUrl == null ||
            (expiresAt != null &&
                DateTime.now().isAfter(
                  expiresAt.subtract(const Duration(seconds: 10)),
                )));

    if (!mustRefresh) {
      await _prepareAudioSource(current);
      return current;
    }

    final resolved = await _resolvePlaybackSource(current.bundle!.trackId);

    final updated = current.copyWith(
      streamUrl: resolved.streamUrl,
      streamExpiresAt: resolved.streamExpiresAt,
      localFilePath: resolved.localFilePath,
      isBuffering: false,
    );

    await _prepareAudioSource(updated, force: true);

    if (updated.positionSeconds > 0) {
      await _audioPlayer.seek(
        Duration(milliseconds: (updated.positionSeconds * 1000).round()),
      );
    }

    state = AsyncData(updated);
    return updated;
  }

  Future<void> _prepareAudioSource(
    PlayerState playerState, {
    bool force = false,
  }) async {
    final activeBundle = playerState.bundle;
    if (activeBundle == null) return;

    final sourceKey = playerState.localFilePath ?? playerState.streamUrl?.url;

    if (!force &&
        _loadedTrackId == activeBundle.trackId &&
        _loadedSourceKey == sourceKey) {
      return;
    }

    if (playerState.localFilePath != null &&
        playerState.localFilePath!.trim().isNotEmpty) {
      await _audioPlayer.setFilePath(playerState.localFilePath!);
    } else if (playerState.streamUrl?.url.trim().isNotEmpty == true) {
      await _audioPlayer.setUrl(playerState.streamUrl!.url);
    }

    _loadedTrackId = activeBundle.trackId;
    _loadedSourceKey = sourceKey;
  }

  Future<void> _applyVolume(PlayerState playerState) async {
    final targetVolume = playerState.isMuted ? 0.0 : playerState.volume;
    await _audioPlayer.setVolume(
      targetVolume.clamp(0.0, 1.0).toDouble(),
    );
  }

  void _attachPlayerBindings() {
    if (_bindingsAttached) return;
    _bindingsAttached = true;

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      final current = _current;
      if (current == null || current.bundle == null) return;

      final clamped = _clampPosition(
        current.bundle!,
        position.inMilliseconds / 1000.0,
      );

      if ((clamped - current.positionSeconds).abs() > 0.03) {
        state = AsyncData(
          current.copyWith(positionSeconds: clamped),
        );
      }

      if (current.isPreviewOnly &&
          position.inSeconds >= current.previewEndSeconds) {
        unawaited(_handlePreviewCompletion());
      }
    });

    _durationSubscription = _audioPlayer.durationStream.listen((_) {});

    _playerStateSubscription =
        _audioPlayer.playerStateStream.listen((audioState) {
      final current = _current;
      if (current == null) return;

      final isBuffering = !_isManualSeeking &&
          (audioState.processingState == just_audio.ProcessingState.loading ||
              audioState.processingState ==
                  just_audio.ProcessingState.buffering);

      if (current.isPlaying != audioState.playing ||
          current.isBuffering != isBuffering) {
        state = AsyncData(
          current.copyWith(
            isPlaying: audioState.playing,
            isBuffering: isBuffering,
          ),
        );
      }

      if (audioState.processingState ==
          just_audio.ProcessingState.completed) {
        unawaited(_handlePlaybackCompleted());
      }
    });
  }

  Future<void> _handlePreviewCompletion() async {
    if (_handlingPreviewStop) return;
    _handlingPreviewStop = true;

    try {
      final current = _current;
      if (current == null || current.bundle == null) return;

      _progressReportTimer?.cancel();
      final previewEnd = current.previewEndSeconds.toDouble();

      await _audioPlayer.pause();
      await _audioPlayer.seek(
        Duration(milliseconds: (previewEnd * 1000).round()),
      );

      state = AsyncData(
        current.copyWith(
          isPlaying: false,
          isBuffering: false,
          positionSeconds: previewEnd,
        ),
      );

      await _safeReportEvent(
        PlaybackEvent(
          trackId: current.bundle!.trackId,
          action: PlaybackAction.pause,
          positionSeconds: previewEnd.round(),
        ),
      );
    } finally {
      _handlingPreviewStop = false;
    }
  }

  Future<void> _handlePlaybackCompleted() async {
    if (_handlingCompletion) return;
    _handlingCompletion = true;

    try {
      final current = _current;
      if (current == null || current.bundle == null) return;

      if (current.isPreviewOnly) {
        await _handlePreviewCompletion();
        return;
      }

      if (current.queue != null) {
        final queue = current.queue!;
        final hasNext = queue.currentIndex + 1 < queue.trackIds.length;

        if (hasNext) {
          await next();
          return;
        }

        if (queue.repeat == RepeatMode.all && queue.trackIds.isNotEmpty) {
          await _jumpToIndex(0, queue, autoPlay: true);
          return;
        }
      }

      _progressReportTimer?.cancel();
      final finalPosition = current.bundle!.durationSeconds.toDouble();

      await _audioPlayer.pause();
      await _audioPlayer.seek(
        Duration(milliseconds: (finalPosition * 1000).round()),
      );

      state = AsyncData(
        current.copyWith(
          isPlaying: false,
          isBuffering: false,
          positionSeconds: finalPosition,
        ),
      );
    } finally {
      _handlingCompletion = false;
    }
  }

  void _startProgressReporting() {
    _progressReportTimer?.cancel();

    _progressReportTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      final current = _current;
      if (current == null || current.bundle == null || !current.isPlaying) {
        _progressReportTimer?.cancel();
        return;
      }

      unawaited(
        _safeReportEvent(
          PlaybackEvent(
            trackId: current.bundle!.trackId,
            action: PlaybackAction.progress,
            positionSeconds: _audioPlayer.position.inSeconds,
          ),
        ),
      );
    });
  }

  int _initialPositionFor(TrackPlaybackBundle bundle) {
    if (bundle.playability.isPreviewOnly && bundle.preview.enabled) {
      return bundle.preview.previewStartSeconds;
    }
    return 0;
  }

  double _clampPosition(TrackPlaybackBundle bundle, double positionSeconds) {
    final maxPosition =
        bundle.playability.isPreviewOnly && bundle.preview.enabled
            ? bundle.preview.previewStartSeconds +
                bundle.preview.previewDurationSeconds
            : bundle.durationSeconds;

    final minPosition =
        bundle.playability.isPreviewOnly && bundle.preview.enabled
            ? bundle.preview.previewStartSeconds
            : 0;

    return positionSeconds
        .clamp(minPosition.toDouble(), maxPosition.toDouble())
        .toDouble();
  }

  Future<void> _safeReportEvent(PlaybackEvent event) async {
    try {
      await _reportEvent(event);
    } catch (_) {
      // Keep playback working even if reporting is unsupported or fails.
    }
  }
}

final playerProvider =
    AsyncNotifierProvider<PlayerNotifier, PlayerState>(PlayerNotifier.new);