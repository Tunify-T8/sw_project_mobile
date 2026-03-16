class SocialUserEntity {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? coverUrl;
  final String? userType;
  final int? followersCount;
  final int? followingCount;
  final int? tracksUploadedCount;
  final int? mutualFollowersCount;
  final bool isVerified;
  final bool isFollowing;
  final bool isNotificationEnabled;
  final String? blockedAt;

  const SocialUserEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.coverUrl,
    this.userType,
    this.followersCount,
    this.followingCount,
    this.tracksUploadedCount,
    this.mutualFollowersCount,
    this.isVerified = false,
    this.isFollowing = false,
    this.isNotificationEnabled = false,
    this.blockedAt,
  });

  SocialUserEntity copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? coverUrl,
    String? userType,
    int? followersCount,
    int? followingCount,
    int? tracksUploadedCount,
    int? mutualFollowersCount,
    bool? isVerified,
    bool? isFollowing,
    bool? isNotificationEnabled,
    String? blockedAt,
  }) {
    return SocialUserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      userType: userType ?? this.userType,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      tracksUploadedCount: tracksUploadedCount ?? this.tracksUploadedCount,
      mutualFollowersCount:
          mutualFollowersCount ?? this.mutualFollowersCount,
      isVerified: isVerified ?? this.isVerified,
      isFollowing: isFollowing ?? this.isFollowing,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      blockedAt: blockedAt ?? this.blockedAt,
    );
  }
}