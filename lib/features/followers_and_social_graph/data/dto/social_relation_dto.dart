class SocialRelationDTO {
  final bool isFollowing;
  final bool isBlocked;

  SocialRelationDTO({
    required this.isFollowing,
    required this.isBlocked,
  });

  factory SocialRelationDTO.fromJson(Map<String, dynamic> json) {
    return SocialRelationDTO(
      isFollowing: json['isFollowing'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
    );
  }
}
