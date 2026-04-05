import '../dto/social_relation_dto.dart';
import '../../domain/entities/social_relation_entity.dart';

extension SocialRelationDtoMapper on SocialRelationDTO {
  SocialRelationEntity toEntity(String targetUserId) {
    return SocialRelationEntity(
      targetUserId: targetUserId,
      isFollowing: isFollowing,
      isBlocked: isBlocked,
    );
  }
}
