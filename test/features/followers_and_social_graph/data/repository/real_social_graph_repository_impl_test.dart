import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/data/api/social_api.dart';
import 'package:software_project/features/followers_and_social_graph/data/dto/social_relation_dto.dart';
import 'package:software_project/features/followers_and_social_graph/data/dto/social_user_dto.dart';
import 'package:software_project/features/followers_and_social_graph/data/repository/real_social_graph_repository_impl.dart';

void main() {
  late FakeSocialApi api;
  late SocialGraphRepositoryImpl repository;

  setUp(() {
    api = FakeSocialApi();
    repository = SocialGraphRepositoryImpl(api);
  });

  test('delegates relationship mutations to the API', () async {
    await repository.followUser('u1');
    await repository.unfollowUser('u2');
    await repository.blockUser('u3');
    await repository.unblockUser('u4');

    expect(api.calls, [
      'follow:u1',
      'unfollow:u2',
      'block:u3',
      'unblock:u4',
    ]);
  });

  test('maps follow status DTO to entity with target user id', () async {
    api.relation = SocialRelationDTO(isFollowing: true, isBlocked: true);

    final result = await repository.getFollowStatus('target');

    expect(result.targetUserId, 'target');
    expect(result.isFollowing, isTrue);
    expect(result.isBlocked, isTrue);
  });

  test('maps every user-list API method to entities', () async {
    api.users = [
      const SocialUserDTO(
        id: 'user-1',
        username: 'artist',
        avatarUrl: 'avatar',
        location: 'Cairo',
        followersCount: 10,
        isCertified: true,
        isFollowing: true,
        isBlocked: false,
        isNotificationEnabled: true,
      ),
    ];

    final methods = [
      repository.getUserFollowers(userId: 'target', page: 2, limit: 3),
      repository.getUserFollowing(userId: 'target', page: 2, limit: 3),
      repository.getMyFollowers(page: 2, limit: 3),
      repository.getMyFollowing(page: 2, limit: 3),
      repository.getBlockedUsers(page: 2, limit: 3),
      repository.getTrueFriends(page: 2, limit: 3),
      repository.getSuggestedUsers(page: 2, limit: 3),
      repository.getSuggestedArtists(page: 2, limit: 3),
    ];

    for (final future in methods) {
      final result = await future;
      expect(result.single.id, 'user-1');
      expect(result.single.username, 'artist');
      expect(result.single.avatarUrl, 'avatar');
      expect(result.single.location, 'Cairo');
      expect(result.single.followersCount, 10);
      expect(result.single.isCertified, isTrue);
      expect(result.single.isFollowing, isTrue);
      expect(result.single.isNotificationEnabled, isTrue);
    }

    expect(api.calls, containsAll([
      'userFollowers:target:2:3',
      'userFollowing:target:2:3',
      'myFollowers:2:3',
      'myFollowing:2:3',
      'blocked:2:3',
      'trueFriends:2:3',
      'suggestedUsers:2:3',
      'suggestedArtists:2:3',
    ]));
  });

  test('doesUserFollowMe returns true when my user appears in following page', () async {
    api.followingPages = {
      1: List.generate(
        100,
        (index) => SocialUserDTO(id: 'other-$index', username: 'user $index'),
      ),
      2: const [
        SocialUserDTO(id: 'me', username: 'current user'),
      ],
    };

    final result = await repository.doesUserFollowMe('other', 'me');

    expect(result, isTrue);
    expect(api.calls, [
      'userFollowing:other:1:100',
      'userFollowing:other:2:100',
    ]);
  });

  test('doesUserFollowMe returns false after short page without match', () async {
    api.followingPages = {
      1: const [
        SocialUserDTO(id: 'someone-else', username: 'other user'),
      ],
    };

    final result = await repository.doesUserFollowMe('other', 'me');

    expect(result, isFalse);
    expect(api.calls, ['userFollowing:other:1:100']);
  });

  test('doesUserFollowMe returns false after max full pages without match', () async {
    api.followingPages = {
      for (var page = 1; page <= 20; page++)
        page: List.generate(
          100,
          (index) => SocialUserDTO(
            id: 'page-$page-user-$index',
            username: 'user $index',
          ),
        ),
    };

    final result = await repository.doesUserFollowMe('other', 'me');

    expect(result, isFalse);
    expect(api.calls.length, 20);
    expect(api.calls.last, 'userFollowing:other:20:100');
  });
}

class FakeSocialApi extends SocialApi {
  FakeSocialApi() : super(Dio());

  final calls = <String>[];
  SocialRelationDTO relation = SocialRelationDTO(
    isFollowing: false,
    isBlocked: false,
  );
  List<SocialUserDTO> users = const [];
  Map<int, List<SocialUserDTO>>? followingPages;

  @override
  Future<void> followUser(String userId) async {
    calls.add('follow:$userId');
  }

  @override
  Future<void> unfollowUser(String userId) async {
    calls.add('unfollow:$userId');
  }

  @override
  Future<void> blockUser(String userId) async {
    calls.add('block:$userId');
  }

  @override
  Future<void> unblockUser(String userId) async {
    calls.add('unblock:$userId');
  }

  @override
  Future<SocialRelationDTO> getFollowStatus(String userId) async {
    calls.add('status:$userId');
    return relation;
  }

  @override
  Future<List<SocialUserDTO>> getUserFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    calls.add('userFollowers:$userId:$page:$limit');
    return users;
  }

  @override
  Future<List<SocialUserDTO>> getUserFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    calls.add('userFollowing:$userId:$page:$limit');
    final pages = followingPages;
    if (pages != null) {
      return pages[page] ?? const [];
    }
    return users;
  }

  @override
  Future<List<SocialUserDTO>> getMyFollowers({int page = 1, int limit = 20}) async {
    calls.add('myFollowers:$page:$limit');
    return users;
  }

  @override
  Future<List<SocialUserDTO>> getMyFollowing({int page = 1, int limit = 20}) async {
    calls.add('myFollowing:$page:$limit');
    return users;
  }

  @override
  Future<List<SocialUserDTO>> getBlockedUsers({int page = 1, int limit = 20}) async {
    calls.add('blocked:$page:$limit');
    return users;
  }

  @override
  Future<List<SocialUserDTO>> getTrueFriends({int page = 1, int limit = 20}) async {
    calls.add('trueFriends:$page:$limit');
    return users;
  }

  @override
  Future<List<SocialUserDTO>> getSuggestedUsers({int page = 1, int limit = 20}) async {
    calls.add('suggestedUsers:$page:$limit');
    return users;
  }

  @override
  Future<List<SocialUserDTO>> getSuggestedArtists({int page = 1, int limit = 20}) async {
    calls.add('suggestedArtists:$page:$limit');
    return users;
  }
}
