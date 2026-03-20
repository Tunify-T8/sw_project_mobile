import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/data/dto/social_user_dto.dart';
import 'package:software_project/features/followers_and_social_graph/data/mappers/social_user_mapper.dart';

void main() {
  group('SocialUserDtoMapper.toEntity', () {
    test('maps every field correctly to SocialUserEntity', () {
      const dto = SocialUserDTO(
        id: 'user-99',
        username: 'mapper_user',
        avatarUrl: 'https://example.com/avatar.png',
        coverUrl: 'https://example.com/cover.png',
        userType: 'LISTENER',
        location: 'Alexandria',
        followersCount: 300,
        followingCount: 120,
        tracksUploadedCount: 14,
        mutualFollowersCount: 9,
        isVerified: true,
        isFollowing: true,
        isNotificationEnabled: true,
        isBlocked: false,
      );

      final entity = dto.toEntity();

      expect(entity.id, dto.id);
      expect(entity.username, dto.username);
      expect(entity.avatarUrl, dto.avatarUrl);
      expect(entity.coverUrl, dto.coverUrl);
      expect(entity.userType, dto.userType);
      expect(entity.location, dto.location);
      expect(entity.followersCount, dto.followersCount);
      expect(entity.followingCount, dto.followingCount);
      expect(entity.tracksUploadedCount, dto.tracksUploadedCount);
      expect(entity.mutualFollowersCount, dto.mutualFollowersCount);
      expect(entity.isVerified, dto.isVerified);
      expect(entity.isFollowing, dto.isFollowing);
      expect(entity.isNotificationEnabled, dto.isNotificationEnabled);
      expect(entity.isBlocked, dto.isBlocked);
    });
  });
}
