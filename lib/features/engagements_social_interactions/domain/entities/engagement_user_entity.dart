class EngagementUserEntity {
  final String id;
  final String displayName;
  final String? avatarUrl;
  const EngagementUserEntity({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });
}

