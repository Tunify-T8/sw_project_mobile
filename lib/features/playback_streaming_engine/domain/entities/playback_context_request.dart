import 'playback_status.dart';

/// What to send when requesting a queue from a given context.
class PlaybackContextRequest {
  const PlaybackContextRequest({
    required this.contextType,
    required this.contextId,
    this.startTrackId,
    this.shuffle = false,
    this.repeat = RepeatMode.none,
  });

  final PlaybackContextType contextType;
  final String contextId;
  final String? startTrackId;
  final bool shuffle;
  final RepeatMode repeat;
}
