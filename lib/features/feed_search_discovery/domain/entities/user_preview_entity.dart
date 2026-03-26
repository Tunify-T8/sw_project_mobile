class UserPreviewEntity {
  final String id;
  final String username;
  final String? avatarUrl;
  final int followersCount;
  final bool verified;
  final String? location;
  final bool isFollowing;

  UserPreviewEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.followersCount,
    required this.verified,
    this.location,
    required this.isFollowing,
  });

  UserPreviewEntity copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    int? followersCount,
    bool? verified,
    String? location,
    bool? isFollowing,
  }) {
    return UserPreviewEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followersCount: followersCount ?? this.followersCount,
      verified: verified ?? this.verified,
      location: location ?? this.location,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}