// ─── Playlist search result ──────────────────────────────────────────────────
class PlaylistResultEntity {
  final String id;
  final String title;
  final String creatorId;
  final String creatorName;
  final String? artworkUrl;
  final int trackCount;
  final int likesCount; // added for display
  final bool isLiked;

  const PlaylistResultEntity({
    required this.id,
    required this.title,
    this.creatorId = '',
    required this.creatorName,
    this.artworkUrl,
    required this.trackCount,
    this.likesCount = 0,
    this.isLiked = false,
  });
}
