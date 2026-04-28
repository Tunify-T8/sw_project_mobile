// ─── Profile search result ───────────────────────────────────────────────────
/// Domain entity representing a user returned from search/people results.
class ProfileResultEntity {
  final String id;
  final String username;

  /// The user's chosen display name. May be null or empty if not set.
  /// When non-null/non-empty this should be shown in the UI over [username].
  final String? displayName;

  final String? avatarUrl;
  final String? location;
  final int followersCount;
  final bool isCertified;
  final bool isFollowing;

  const ProfileResultEntity({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.location,
    required this.followersCount,
    this.isCertified = false,
    this.isFollowing = false,
  });

  /// The name that should be rendered in UI tiles and suggestion rows.
  String get displayLabel => (displayName != null && displayName!.isNotEmpty)
      ? displayName!
      : username;
}
