import '../dto/social_user_dto.dart';
import '../../domain/entities/social_user_entity.dart';

extension SocialUserDtoMapper on SocialUserDTO {
  SocialUserEntity toEntity() {
    return SocialUserEntity(
      id: id,
      username: username,
      avatarUrl: avatarUrl,
      location: location,
      followersCount: followersCount,
      isCertified: isCertified,
      isFollowing: isFollowing,
      isNotificationEnabled: isNotificationEnabled,
      isBlocked: isBlocked,
    );
  }
}
