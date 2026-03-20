import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/data/services/mock_social_graph_service.dart';

void main() {
  late MockSocialGraphService service;

  setUp(() {
    service = MockSocialGraphService();
  });

  group('MockSocialGraphService', () {
    test('getFollowers returns paginated followers with expected pattern', () async {
      final result = await service.getFollowers(
        userId: 'user_1',
        page: 2,
        limit: 3,
      );

      expect(result.length, 3);

      expect(result[0]['id'], 'follower_4');
      expect(result[0]['username'], 'follower_user_4');
      expect(result[0]['location'], 'Cairo, Egypt');
      expect(result[0]['isFollowing'], true);
      expect(result[0]['isVerified'], false);
      expect(result[0]['isBlocked'], false);
      expect(result[0]['followersCount'], 104);
      expect(result[0]['followingCount'], 54);

      expect(result[1]['id'], 'follower_5');
      expect(result[1]['location'], 'Alexandria, Egypt');
      expect(result[1]['isFollowing'], false);

      expect(result[2]['id'], 'follower_6');
      expect(result[2]['isVerified'], true);
    });

    test('getFollowing returns paginated following users with expected pattern', () async {
      final result = await service.getFollowing(
        userId: 'user_1',
        page: 1,
        limit: 4,
      );

      expect(result.length, 4);

      expect(result[0]['id'], 'following_1');
      expect(result[0]['username'], 'following_user_1');
      expect(result[0]['location'], 'Mansoura, Egypt');
      expect(result[0]['isFollowing'], true);
      expect(result[0]['isNotificationEnabled'], false);
      expect(result[0]['isVerified'], false);

      expect(result[1]['location'], 'Giza, Egypt');
      expect(result[1]['isNotificationEnabled'], true);

      expect(result[2]['isVerified'], true);
    });

    test('followUser completes successfully', () async {
      await expectLater(
        service.followUser(userId: 'user_1'),
        completes,
      );
    });

    test('unfollowUser completes successfully', () async {
      await expectLater(
        service.unfollowUser(userId: 'user_1'),
        completes,
      );
    });

    test('blockUser completes successfully', () async {
      await expectLater(
        service.blockUser(userId: 'user_1'),
        completes,
      );
    });

    test('unblockUser completes successfully', () async {
      await expectLater(
        service.unblockUser(userId: 'user_1'),
        completes,
      );
    });

    test('getBlockedUsers returns blocked users with expected pattern', () async {
      final result = await service.getBlockedUsers(page: 1, limit: 3);

      expect(result.length, 3);

      expect(result[0]['id'], 'blocked_1');
      expect(result[0]['username'], 'blocked_user_1');
      expect(result[0]['location'], 'Aswan, Egypt');
      expect(result[0]['isBlocked'], true);
      expect(result[0]['isFollowing'], false);
      expect(result[0]['isVerified'], false);

      expect(result[1]['location'], 'Tanta, Egypt');
      expect(result.every((user) => user['isBlocked'] == true), true);
    });

    test('getSuggestedUsers includes genre when provided', () async {
      final result = await service.getSuggestedUsers(
        page: 1,
        limit: 3,
        genre: 'Pop',
      );

      expect(result.length, 3);

      expect(result[0]['id'], 'suggested_1');
      expect(result[0]['username'], 'suggested_user_1');
      expect(result[0]['location'], 'Beirut, Lebanon');
      expect(result[0]['userType'], 'LISTENER');
      expect(result[0]['mutualFollowersCount'], 1);
      expect(result[0]['tracksUploadedCount'], 2);
      expect(result[0]['isVerified'], false);
      expect(result[0]['isFollowing'], false);
      expect(result[0]['isBlocked'], false);
      expect(result[0]['genre'], 'Pop');

      expect(result[1]['location'], 'Dubai, UAE');
      expect(result[1]['userType'], 'ARTIST');
      expect(result[1]['genre'], 'Pop');
    });

    test('getSuggestedUsers omits genre when not provided', () async {
      final result = await service.getSuggestedUsers(
        page: 1,
        limit: 2,
      );

      expect(result.length, 2);
      expect(result[0].containsKey('genre'), false);
      expect(result[1].containsKey('genre'), false);
    });

    test('getFollowStatus returns expected relation flags', () async {
      const userId = 'user_123';

      final result = await service.getFollowStatus(userId: userId);

      final expectedIsFollowedBy = userId.hashCode.isEven;

      expect(result['isFollowing'], true);
      expect(result['isFollowedBy'], expectedIsFollowedBy);
      expect(result['isMutual'], expectedIsFollowedBy);
      expect(result['isBlocked'], false);
    });

    test('getMutualFriends returns paginated mutual friends with expected pattern', () async {
      final result = await service.getMutualFriends(
        userId: 'user_1',
        page: 1,
        limit: 3,
      );

      expect(result.length, 3);

      expect(result[0]['id'], 'mutual_1');
      expect(result[0]['username'], 'mutual_friend_1');
      expect(result[0]['location'], 'Riyadh, Saudi Arabia');
      expect(result[0]['isFollowing'], true);
      expect(result[0]['isVerified'], false);
      expect(result[0]['isBlocked'], false);
      expect(result[0]['mutualFollowersCount'], 4);

      expect(result[1]['location'], 'Amman, Jordan');
      expect(result[1]['mutualFollowersCount'], 5);

      expect(result[2]['mutualFollowersCount'], 6);
    });
  });
}