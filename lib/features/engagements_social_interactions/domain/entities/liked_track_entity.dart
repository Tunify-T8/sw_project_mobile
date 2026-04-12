/// Represents a track that the viewer has liked.
/// On a real backend this is returned by GET /users/me/likes
class LikedTrackEntity {
  final String trackId;
  final String title;
  final String artistId;
  final String artistName;
  final String? artistAvatar;
  final bool artistVerified;
  final String? coverUrl;
  final int duration;      // seconds
  final int likesCount;
  final int commentsCount;
  final DateTime likedAt;

  const LikedTrackEntity({
    required this.trackId,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.artistAvatar,
    this.artistVerified = false,
    this.coverUrl,
    required this.duration,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.likedAt,
  });
}
