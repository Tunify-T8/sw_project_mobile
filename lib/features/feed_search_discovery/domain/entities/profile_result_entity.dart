// ─── Profile search result ───────────────────────────────────────────────────
class ProfileResultEntity {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? location;
  final int followersCount;
  final bool isVerified;
  final bool isFollowing;

  const ProfileResultEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.location,
    required this.followersCount,
    this.isVerified = false,
    this.isFollowing = false,
  });
}
