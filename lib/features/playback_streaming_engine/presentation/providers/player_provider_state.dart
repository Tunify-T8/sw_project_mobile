part of 'player_provider.dart';

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
}
