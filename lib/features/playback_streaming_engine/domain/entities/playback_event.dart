enum PlaybackAction { play, progress, pause }

/// Payload the client sends when reporting a player state change.
class PlaybackEvent {
  const PlaybackEvent({
    required this.trackId,
    required this.action,
    required this.positionSeconds,
  });

  final String trackId;
  final PlaybackAction action;
  final int positionSeconds;
}
