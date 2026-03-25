class UserPreviewDto {
  final String id;
  final String username;
  final int followersCount;
  final bool verified;
  final String? location;

  UserPreviewDto({
    required this.id,
    required this.username,
    required this.followersCount,
    required this.verified,
    this.location,
  });

  factory UserPreviewDto.fromJson(Map<String, dynamic> json) {
    return UserPreviewDto(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      followersCount: json['followersCount'] ?? 0,
      verified: json['verified'] ?? false,
      location: json['location'],
    );
  }
}