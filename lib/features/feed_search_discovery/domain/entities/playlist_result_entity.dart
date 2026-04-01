// ─── Playlist search result ──────────────────────────────────────────────────
class PlaylistResultEntity {
  final String id;
  final String title;
  final String creatorName;
  final String? artworkUrl;
  final int trackCount;
  final int likesCount; // added for display

  const PlaylistResultEntity({
    required this.id,
    required this.title,
    required this.creatorName,
    this.artworkUrl,
    required this.trackCount,
    this.likesCount = 0,
  });
}
