class SocialRelationEntity {
  final String targetUserId;
  final bool isFollowing;
  final bool isBlocked;

  const SocialRelationEntity({
    required this.targetUserId,
    required this.isFollowing,
    this.isBlocked = false,
  });

  SocialRelationEntity copyWith({
    String? targetUserId,
    bool? isFollowing,
    bool? isBlocked,
  }) {
    return SocialRelationEntity(
      targetUserId: targetUserId ?? this.targetUserId,
      isFollowing: isFollowing ?? this.isFollowing,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
