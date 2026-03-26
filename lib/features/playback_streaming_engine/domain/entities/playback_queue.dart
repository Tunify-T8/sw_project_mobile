import 'playback_status.dart';

/// Ordered playback queue resolved from a context source.
class PlaybackQueue {
  const PlaybackQueue({
    required this.trackIds,
    required this.currentIndex,
    required this.shuffle,
    required this.repeat,
  });

  final List<String> trackIds;
  final int currentIndex;
  final bool shuffle;
  final RepeatMode repeat;

  String? get currentTrackId {
    if (trackIds.isEmpty) return null;
    if (currentIndex < 0 || currentIndex >= trackIds.length) return null;
    return trackIds[currentIndex];
  }

  PlaybackQueue copyWith({
    List<String>? trackIds,
    int? currentIndex,
    bool? shuffle,
    RepeatMode? repeat,
  }) {
    return PlaybackQueue(
      trackIds: trackIds ?? this.trackIds,
      currentIndex: currentIndex ?? this.currentIndex,
      shuffle: shuffle ?? this.shuffle,
      repeat: repeat ?? this.repeat,
    );
  }
}
