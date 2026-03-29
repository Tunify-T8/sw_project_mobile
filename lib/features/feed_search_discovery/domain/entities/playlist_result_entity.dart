// ─── Playlist search result ──────────────────────────────────────────────────
class PlaylistResultEntity {
  final String id;
  final String title;
  final String creatorName;
  final String? artworkUrl;
  final int trackCount;

  const PlaylistResultEntity({
    required this.id,
    required this.title,
    required this.creatorName,
    this.artworkUrl,
    required this.trackCount,
  });
}
