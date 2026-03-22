/// Mirrors the API's `PlayabilityStatus.status` field.
enum PlaybackStatus { playable, preview, blocked }

enum BlockedReason {
  regionRestricted,
  tierRestricted,
  scheduledRelease,
  deleted,
  privateNoToken,
  copyright,
}

enum RepeatMode { none, one, all }

enum PlaybackContextType { track, playlist, feed, profile, history }
