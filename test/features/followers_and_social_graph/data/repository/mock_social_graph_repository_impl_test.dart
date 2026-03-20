import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/followers_and_social_graph/data/repository/mock_social_graph_repository_impl.dart';
import 'package:software_project/features/followers_and_social_graph/data/services/mock_social_graph_service.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_relation_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_user_entity.dart';

import 'mock_social_graph_repository_impl_test.mocks.dart';

@GenerateMocks([MockSocialGraphService])
void main() {
  late MockMockSocialGraphService mockService;
  late MockSocialGraphRepositoryImpl repository;

  setUp(() {
    mockService = MockMockSocialGraphService();
    repository = MockSocialGraphRepositoryImpl(service: mockService);
  });

  group('MockSocialGraphRepositoryImpl', () {
    test('getFollowers delegates to service and maps result', () async {
      when(
        mockService.getFollowers(
          userId: 'user_1',
          page: 2,
          limit: 2,
        ),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'follower_3',
            'username': 'follower_user_3',
            'avatarUrl': null,
            'location': 'Alexandria, Egypt',
            'isFollowing': false,
            'isVerified': true,
            'isBlocked': false,
            'followersCount': 103,
            'followingCount': 53,
          },
          {
            'id': 'follower_4',
            'username': 'follower_user_4',
            'avatarUrl': null,
            'location': 'Cairo, Egypt',
            'isFollowing': true,
            'isVerified': false,
            'isBlocked': false,
            'followersCount': 104,
            'followingCount': 54,
          },
        ],
      );

      final result = await repository.getFollowers(
        userId: 'user_1',
        page: 2,
        limit: 2,
      );

      expect(result, isA<List<SocialUserEntity>>());
      expect(result.length, 2);
      expect(result.first.id, 'follower_3');
      expect(result.first.username, 'follower_user_3');
      expect(result.first.isVerified, true);

      verify(
        mockService.getFollowers(
          userId: 'user_1',
          page: 2,
          limit: 2,
        ),
      ).called(1);
    });

    test('getFollowing delegates to service and maps result', () async {
      when(
        mockService.getFollowing(
          userId: 'user_1',
          page: 1,
          limit: 2,
        ),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'following_1',
            'username': 'following_user_1',
            'avatarUrl': null,
            'location': 'Mansoura, Egypt',
            'isFollowing': true,
            'isVerified': false,
            'isNotificationEnabled': false,
            'isBlocked': false,
            'followersCount': 201,
            'followingCount': 81,
          },
          {
            'id': 'following_2',
            'username': 'following_user_2',
            'avatarUrl': null,
            'location': 'Giza, Egypt',
            'isFollowing': true,
            'isVerified': false,
            'isNotificationEnabled': true,
            'isBlocked': false,
            'followersCount': 202,
            'followingCount': 82,
          },
        ],
      );

      final result = await repository.getFollowing(
        userId: 'user_1',
        page: 1,
        limit: 2,
      );

      expect(result, isA<List<SocialUserEntity>>());
      expect(result.length, 2);
      expect(result[1].id, 'following_2');
      expect(result[1].isFollowing, true);

      verify(
        mockService.getFollowing(
          userId: 'user_1',
          page: 1,
          limit: 2,
        ),
      ).called(1);
    });

    test('followUser delegates to service', () async {
      when(mockService.followUser(userId: 'user_1'))
          .thenAnswer((_) async {});

      await repository.followUser('user_1');

      verify(mockService.followUser(userId: 'user_1')).called(1);
    });

    test('unfollowUser delegates to service', () async {
      when(mockService.unfollowUser(userId: 'user_1'))
          .thenAnswer((_) async {});

      await repository.unfollowUser('user_1');

      verify(mockService.unfollowUser(userId: 'user_1')).called(1);
    });

    test('blockUser delegates to service', () async {
      when(mockService.blockUser(userId: 'user_1'))
          .thenAnswer((_) async {});

      await repository.blockUser('user_1');

      verify(mockService.blockUser(userId: 'user_1')).called(1);
    });

    test('unblockUser delegates to service', () async {
      when(mockService.unblockUser(userId: 'user_1'))
          .thenAnswer((_) async {});

      await repository.unblockUser('user_1');

      verify(mockService.unblockUser(userId: 'user_1')).called(1);
    });

    test('getBlockedUsers delegates to service and maps result', () async {
      when(
        mockService.getBlockedUsers(page: 1, limit: 2),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'blocked_1',
            'username': 'blocked_user_1',
            'avatarUrl': null,
            'location': 'Aswan, Egypt',
            'isFollowing': false,
            'isVerified': false,
            'isBlocked': true,
            'followersCount': 21,
            'followingCount': 11,
          },
          {
            'id': 'blocked_2',
            'username': 'blocked_user_2',
            'avatarUrl': null,
            'location': 'Tanta, Egypt',
            'isFollowing': false,
            'isVerified': false,
            'isBlocked': true,
            'followersCount': 22,
            'followingCount': 12,
          },
        ],
      );

      final result = await repository.getBlockedUsers(page: 1, limit: 2);

      expect(result, isA<List<SocialUserEntity>>());
      expect(result.length, 2);
      expect(result.every((user) => user.isBlocked), true);

      verify(mockService.getBlockedUsers(page: 1, limit: 2)).called(1);
    });

    test('getSuggestedUsers delegates to service and maps result', () async {
      when(
        mockService.getSuggestedUsers(page: 1, limit: 2, genre: 'Pop'),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'suggested_1',
            'username': 'suggested_user_1',
            'avatarUrl': null,
            'coverUrl': null,
            'location': 'Beirut, Lebanon',
            'userType': 'LISTENER',
            'mutualFollowersCount': 1,
            'tracksUploadedCount': 2,
            'followersCount': 101,
            'followingCount': 51,
            'isVerified': false,
            'isFollowing': false,
            'isBlocked': false,
            'genre': 'Pop',
          },
          {
            'id': 'suggested_2',
            'username': 'suggested_user_2',
            'avatarUrl': null,
            'coverUrl': null,
            'location': 'Dubai, UAE',
            'userType': 'ARTIST',
            'mutualFollowersCount': 2,
            'tracksUploadedCount': 4,
            'followersCount': 102,
            'followingCount': 52,
            'isVerified': false,
            'isFollowing': false,
            'isBlocked': false,
            'genre': 'Pop',
          },
        ],
      );

      final result = await repository.getSuggestedUsers(
        page: 1,
        limit: 2,
        genre: 'Pop',
      );

      expect(result, isA<List<SocialUserEntity>>());
      expect(result.length, 2);
      expect(result.first.id, 'suggested_1');
      expect(result.first.userType, 'LISTENER');

      verify(
        mockService.getSuggestedUsers(
          page: 1,
          limit: 2,
          genre: 'Pop',
        ),
      ).called(1);
    });

    test('getFollowStatus delegates to service and maps result', () async {
      when(
        mockService.getFollowStatus(userId: 'target_1'),
      ).thenAnswer(
        (_) async => {
          'isFollowing': true,
          'isFollowedBy': false,
          'isMutual': false,
          'isBlocked': false,
        },
      );

      final result = await repository.getFollowStatus('target_1');

      expect(result, isA<SocialRelationEntity>());
      expect(result.targetUserId, 'target_1');
      expect(result.isFollowing, true);
      expect(result.isFollowedBy, false);
      expect(result.isMutual, false);
      expect(result.isBlocked, false);

      verify(mockService.getFollowStatus(userId: 'target_1')).called(1);
    });

    test('getMutualFriends delegates to service and maps result', () async {
      when(
        mockService.getMutualFriends(
          userId: 'user_1',
          page: 1,
          limit: 2,
        ),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'mutual_1',
            'username': 'mutual_friend_1',
            'avatarUrl': null,
            'location': 'Riyadh, Saudi Arabia',
            'isFollowing': true,
            'isVerified': false,
            'isBlocked': false,
            'mutualFollowersCount': 4,
          },
          {
            'id': 'mutual_2',
            'username': 'mutual_friend_2',
            'avatarUrl': null,
            'location': 'Amman, Jordan',
            'isFollowing': true,
            'isVerified': false,
            'isBlocked': false,
            'mutualFollowersCount': 5,
          },
        ],
      );

      final result = await repository.getMutualFriends(
        userId: 'user_1',
        page: 1,
        limit: 2,
      );

      expect(result, isA<List<SocialUserEntity>>());
      expect(result.length, 2);
      expect(result.first.id, 'mutual_1');
      expect(result.first.mutualFollowersCount, 4);

      verify(
        mockService.getMutualFriends(
          userId: 'user_1',
          page: 1,
          limit: 2,
        ),
      ).called(1);
    });
  });
}