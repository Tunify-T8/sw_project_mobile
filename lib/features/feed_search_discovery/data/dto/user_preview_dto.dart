class UserPreviewDto {
  final String id;
  final String username;
  final String? avatarUrl;
  final int followersCount;
  final bool isCertified;
  final String? location;
  final bool isFollowing;

  UserPreviewDto({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.followersCount,
    required this.isCertified,
    this.location,
    required this.isFollowing,
  });

  factory UserPreviewDto.fromJson(Map<String, dynamic> json) {
    return UserPreviewDto(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      followersCount: json['followersCount'] ?? 0,
      isCertified: (json['isCertified'] as bool?) ?? (json['verified'] as bool?) ?? false,
      location: json['location']?.toString(),
      isFollowing: json['isFollowing'] ?? false,
    );
  }
}