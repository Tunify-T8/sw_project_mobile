class SocialUserDTO {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? coverUrl;
  final String? location;
  final int? followersCount;
  final bool isCertified;
  final bool isFollowing;
  final bool isBlocked;
  final bool isNotificationEnabled;

  const SocialUserDTO({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.coverUrl,
    this.location,
    this.followersCount,
    this.isCertified = false,
    this.isFollowing = false,
    this.isBlocked = false,
    this.isNotificationEnabled = false,
  });

  factory SocialUserDTO.fromJson(Map<String, dynamic> json) {
    return SocialUserDTO(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
      location: json['location']?.toString(),
      followersCount: json['followersCount'] as int?,
      isCertified: json['isCertified'] ?? false,
      isFollowing: json['isFollowing'] ?? true,
      isBlocked: json['isBlocked'] ?? false,
      isNotificationEnabled: json['isNotificationEnabled'] ?? false,
    );
  }
}
