class SocialUserEntity {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? location;
  final int? followersCount;
  final bool isCertified;
  final bool isFollowing;
  final bool isBlocked;
  final bool isNotificationEnabled;

  const SocialUserEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.location,
    this.followersCount,
    this.isCertified = false,
    this.isFollowing = false,
    this.isBlocked = false,
    this.isNotificationEnabled = false,
  });

  SocialUserEntity copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? location,
    int? followersCount,
    bool? isCertified,
    bool? isFollowing,
    bool? isBlocked,
    bool? isNotificationEnabled,
  }) {
    return SocialUserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      followersCount: followersCount ?? this.followersCount,
      isCertified: isCertified ?? this.isCertified,
      isFollowing: isFollowing ?? this.isFollowing,
      isBlocked: isBlocked ?? this.isBlocked,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }
}
