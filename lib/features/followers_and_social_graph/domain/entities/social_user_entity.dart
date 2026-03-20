class SocialUserEntity {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? coverUrl;
  final String? userType;
  final String? location;
  final int? followersCount;
  final int? followingCount;
  final int? tracksUploadedCount;
  final int? mutualFollowersCount;
  final bool isVerified;
  final bool isFollowing;
  final bool isBlocked;
  final bool isNotificationEnabled;

  const SocialUserEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.coverUrl,
    this.userType,
    this.location,
    this.followersCount,
    this.followingCount,
    this.tracksUploadedCount,
    this.mutualFollowersCount,
    this.isVerified = false,
    this.isFollowing = false,
    this.isBlocked = false,
    this.isNotificationEnabled = false,
  });

  SocialUserEntity copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? coverUrl,
    String? userType,
    String? location,
    int? followersCount,
    int? followingCount,
    int? tracksUploadedCount,
    int? mutualFollowersCount,
    bool? isVerified,
    bool? isFollowing,
    bool? isBlocked,
    bool? isNotificationEnabled,
  }) {
    return SocialUserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      userType: userType ?? this.userType,
      location: location ?? this.location,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      tracksUploadedCount: tracksUploadedCount ?? this.tracksUploadedCount,
      mutualFollowersCount: mutualFollowersCount ?? this.mutualFollowersCount,
      isVerified: isVerified ?? this.isVerified,
      isFollowing: isFollowing ?? this.isFollowing,
      isBlocked: isBlocked ?? this.isBlocked,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }
}
