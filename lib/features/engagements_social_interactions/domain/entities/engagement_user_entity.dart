class EngagementUserEntity {
  final String id;
  final String username;
  final String? avatarUrl;
  const EngagementUserEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
  });
}

