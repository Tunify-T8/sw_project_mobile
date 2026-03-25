import '../../domain/entities/user_preview_entity.dart';
import '../dto/user_preview_dto.dart';

extension UserPreviewMapper on UserPreviewDto {
  UserPreviewEntity toEntity() {
    return UserPreviewEntity(
      id: id,
      username: username,
      avatarUrl: avatarUrl,
      followersCount: followersCount,
      verified: verified,
      location: location,
      isFollowing: isFollowing,
    );
  }
}