// ─── Track search result ─────────────────────────────────────────────────────
class TrackResultEntity {
  final String id;
  final String title;
  final String artistName;
  final String? artworkUrl;
  final int durationSeconds;

  /// e.g. "20.1K" — pre-formatted by backend or formatted locally.
  final String? playCount;

  /// True when the track is region-blocked for the current user.
  final bool isUnavailable;

  const TrackResultEntity({
    required this.id,
    required this.title,
    required this.artistName,
    this.artworkUrl,
    required this.durationSeconds,
    this.playCount,
    this.isUnavailable = false,
  });
}
