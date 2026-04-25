class EngagementUserEntity {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isCertified;
  const EngagementUserEntity({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.isCertified = false,
  });
}

