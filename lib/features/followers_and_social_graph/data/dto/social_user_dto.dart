class SocialUserDTO {
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

  const SocialUserDTO({
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

  factory SocialUserDTO.fromJson(Map<String, dynamic> json) {
    return SocialUserDTO(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      userType: json['userType']?.toString(),
      followersCount: json['followersCount'] as int?,
      followingCount: json['followingCount'] as int?,
      tracksUploadedCount: json['tracksUploadedCount'] as int?,
      mutualFollowersCount: json['mutualFollowersCount'] as int?,
      isVerified: json['isVerified'] ?? false,
      isFollowing: json['isFollowing'] ?? false,
      isNotificationEnabled: json['isNotificationEnabled'] ?? false,
      blockedAt: json['blockedAt']?.toString(),
    );
  }
}