import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_user_entity.dart';

void main() {
  test('copyWith updates selected fields and preserves omitted values', () {
    const user = SocialUserEntity(
      id: 'u1',
      username: 'old',
      avatarUrl: 'avatar',
      location: 'Cairo',
      followersCount: 4,
      isCertified: false,
      isFollowing: false,
      isBlocked: false,
      isNotificationEnabled: false,
    );

    final updated = user.copyWith(
      username: 'new',
      followersCount: 5,
      isCertified: true,
      isFollowing: true,
      isBlocked: true,
      isNotificationEnabled: true,
    );

    expect(updated.id, 'u1');
    expect(updated.username, 'new');
    expect(updated.avatarUrl, 'avatar');
    expect(updated.location, 'Cairo');
    expect(updated.followersCount, 5);
    expect(updated.isCertified, isTrue);
    expect(updated.isFollowing, isTrue);
    expect(updated.isBlocked, isTrue);
    expect(updated.isNotificationEnabled, isTrue);
  });

  test('copyWith can replace identity and nullable profile fields', () {
    const user = SocialUserEntity(
      id: 'old-id',
      username: 'old',
      avatarUrl: 'old-avatar',
      location: 'Old City',
      followersCount: 1,
    );

    final updated = user.copyWith(
      id: 'new-id',
      username: 'new',
      avatarUrl: 'new-avatar',
      location: 'New City',
      followersCount: 2,
    );

    expect(updated.id, 'new-id');
    expect(updated.username, 'new');
    expect(updated.avatarUrl, 'new-avatar');
    expect(updated.location, 'New City');
    expect(updated.followersCount, 2);
  });

  test('copyWith with no arguments preserves every field', () {
    const user = SocialUserEntity(
      id: 'u1',
      username: 'same',
      followersCount: 3,
    );

    final updated = user.copyWith();

    expect(updated.id, user.id);
    expect(updated.username, user.username);
    expect(updated.followersCount, user.followersCount);
  });
}
