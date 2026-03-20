class SocialRelationDTO {
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isMutual;
  final bool isBlocked;

  SocialRelationDTO({
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isMutual,
    required this.isBlocked,
  });

  factory SocialRelationDTO.fromJson(Map<String, dynamic> json) {
    return SocialRelationDTO(
      isFollowing: json['isFollowing'] ?? false,
      isFollowedBy: json['isFollowedBy'] ?? false,
      isMutual: json['isMutual'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
    );
  }
}
