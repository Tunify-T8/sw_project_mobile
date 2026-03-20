class SocialRelationEntity {
  final String targetUserId;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isMutual;
  final bool isBlocked;

  const SocialRelationEntity({
    required this.targetUserId,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isMutual,
    this.isBlocked = false,
  });

  SocialRelationEntity copyWith({
    String? targetUserId,
    bool? isFollowing,
    bool? isFollowedBy,
    bool? isMutual,
    bool? isBlocked,
  }) {
    return SocialRelationEntity(
      targetUserId: targetUserId ?? this.targetUserId,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      isMutual: isMutual ?? this.isMutual,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
