import 'playback_status.dart';

/// Ordered playback queue resolved from a context source.
class PlaybackQueue {
  const PlaybackQueue({
    required this.trackIds,
    required this.currentIndex,
    required this.shuffle,
    required this.repeat,
    this.originalTrackIds,
  });

  final List<String> trackIds;
  final int currentIndex;
  final bool shuffle;
  final RepeatMode repeat;

  /// Pre-shuffle order snapshot. Populated when shuffle is turned ON so that
  /// turning it OFF again restores the natural order. Null when shuffle has
  /// never been toggled on for this queue (or after it has been restored).
  final List<String>? originalTrackIds;

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
    List<String>? originalTrackIds,
    bool clearOriginalTrackIds = false,
  }) {
    return PlaybackQueue(
      trackIds: trackIds ?? this.trackIds,
      currentIndex: currentIndex ?? this.currentIndex,
      shuffle: shuffle ?? this.shuffle,
      repeat: repeat ?? this.repeat,
      originalTrackIds: clearOriginalTrackIds
          ? null
          : (originalTrackIds ?? this.originalTrackIds),
    );
  }
}