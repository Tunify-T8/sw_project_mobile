/// Represents a track that the viewer has reposted.
/// On a real backend this is returned by GET /users/me/reposts
class RepostedTrackEntity {
  final String trackId;
  final String title;
  final String artistId;
  final String artistName;
  final String? artistAvatar;
  final bool artistVerified;
  final String? coverUrl;
  final int duration; // seconds
  final int repostCount;
  final int playCount;
  final DateTime repostedAt;

  const RepostedTrackEntity({
    required this.trackId,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.artistAvatar,
    this.artistVerified = false,
    this.coverUrl,
    required this.duration,
    this.repostCount = 0,
    this.playCount = 0,
    required this.repostedAt,
  });
}
