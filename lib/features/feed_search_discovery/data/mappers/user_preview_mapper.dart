import '../../domain/entities/user_preview_entity.dart';
import '../dto/user_preview_dto.dart';

extension UserPreviewMapper on UserPreviewDto {
  UserPreviewEntity toEntity() {
    return UserPreviewEntity(
      id: id,
      username: username,
      avatarUrl: avatarUrl,
      followersCount: followersCount,
      isCertified: isCertified,
      location: location,
      isFollowing: isFollowing,
    );
  }
}