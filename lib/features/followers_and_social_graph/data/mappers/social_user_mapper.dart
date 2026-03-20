import '../dto/social_user_dto.dart';
import '../../domain/entities/social_user_entity.dart';

extension SocialUserDtoMapper on SocialUserDTO {
  SocialUserEntity toEntity() {
    return SocialUserEntity(
      id: id,
      username: username,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      userType: userType,
      location: location,
      followersCount: followersCount,
      followingCount: followingCount,
      tracksUploadedCount: tracksUploadedCount,
      mutualFollowersCount: mutualFollowersCount,
      isVerified: isVerified,
      isFollowing: isFollowing,
      isNotificationEnabled: isNotificationEnabled,
      isBlocked: isBlocked,
    );
  }
}
