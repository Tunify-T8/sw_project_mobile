import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/network_list_type.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_relation_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_user_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/repositories/social_graph_repository.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/network_lists_notifier.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/social_graph_repository_provider.dart';

void main() {
  late FakeSocialGraphRepository repository;
  late ProviderContainer container;
  late NetworkListsNotifier notifier;

  setUp(() {
    repository = FakeSocialGraphRepository();
    container = ProviderContainer(
      overrides: [socialGraphRepositoryProvider.overrideWithValue(repository)],
    );
    notifier = container.read(networkListsProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  SocialUserEntity user(String id) => SocialUserEntity(
        id: id,
        username: 'user_$id',
      );

  group('NetworkListsNotifier', () {
    test('starts with per-list loading defaults and empty lists', () {
      final state = container.read(networkListsProvider);

      for (final type in NetworkListType.values) {
        expect(state.userLists[type], isNull);
        expect(state.isLoading[type], isTrue);
        expect(state.error[type], isNull);
        expect(state.hasLoadedOnce[type], isFalse);
      }
    });

    test('clearList only clears the requested list', () async {
      repository.myFollowing = [user('one')];
      repository.myFollowers = [user('two')];

      await notifier.loadMyFollowing();
      await notifier.loadMyFollowers();

      notifier.clearList(NetworkListType.following);

      final state = container.read(networkListsProvider);
      expect(state.userLists[NetworkListType.following], isEmpty);
      expect(state.userLists[NetworkListType.followers], repository.myFollowers);
    });

    test('loads every supported list into its own state bucket', () async {
      repository
        ..following = [user('following')]
        ..followers = [user('followers')]
        ..myFollowing = [user('my-following')]
        ..myFollowers = [user('my-followers')]
        ..suggestedUsers = [user('suggested')]
        ..suggestedArtists = [user('artist')]
        ..blockedUsers = [user('blocked')]
        ..trueFriends = [user('true-friend')];

      await notifier.loadFollowingList(userId: 'target', page: 2, limit: 3);
      await notifier.loadFollowersList(userId: 'target', page: 4, limit: 5);
      await notifier.loadMyFollowing(page: 6, limit: 7);
      await notifier.loadMyFollowers(page: 8, limit: 9);
      await notifier.loadSuggestedUsers(page: 10, limit: 11);
      await notifier.loadSuggestedArtists(page: 12, limit: 13);
      await notifier.loadBlockedUsers(page: 14, limit: 15);
      await notifier.loadTrueFriends(page: 16, limit: 17);

      final state = container.read(networkListsProvider);
      expect(state.userLists[NetworkListType.following], repository.myFollowing);
      expect(state.userLists[NetworkListType.followers], repository.myFollowers);
      expect(state.userLists[NetworkListType.suggestedUsers], repository.suggestedUsers);
      expect(state.userLists[NetworkListType.suggestedArtists], repository.suggestedArtists);
      expect(state.userLists[NetworkListType.blocked], repository.blockedUsers);
      expect(state.userLists[NetworkListType.trueFriends], repository.trueFriends);
      for (final type in NetworkListType.values) {
        expect(state.isLoading[type], isFalse);
        expect(state.error[type], isNull);
        expect(state.hasLoadedOnce[type], isTrue);
      }
      expect(repository.lastUserFollowingArgs, ('target', 2, 3));
      expect(repository.lastUserFollowersArgs, ('target', 4, 5));
      expect(repository.lastMyFollowingArgs, (6, 7));
      expect(repository.lastMyFollowersArgs, (8, 9));
      expect(repository.lastSuggestedUsersArgs, (10, 11));
      expect(repository.lastSuggestedArtistsArgs, (12, 13));
      expect(repository.lastBlockedUsersArgs, (14, 15));
      expect(repository.lastTrueFriendsArgs, (16, 17));
    });

    test('stores failures per list and marks the list as loaded once', () async {
      repository.error = StateError('network nope');

      await notifier.loadSuggestedUsers();

      final state = container.read(networkListsProvider);
      expect(state.userLists[NetworkListType.suggestedUsers], isNull);
      expect(state.isLoading[NetworkListType.suggestedUsers], isFalse);
      expect(state.error[NetworkListType.suggestedUsers], 'Bad state: network nope');
      expect(state.hasLoadedOnce[NetworkListType.suggestedUsers], isTrue);
    });

    test('stores failures for following followers my-following blocked and true friends', () async {
      final cases = <(NetworkListType, Future<void> Function())>[
        (NetworkListType.following, () => notifier.loadFollowingList(userId: 'target')),
        (NetworkListType.followers, () => notifier.loadFollowersList(userId: 'target')),
        (NetworkListType.following, () => notifier.loadMyFollowing()),
        (NetworkListType.blocked, () => notifier.loadBlockedUsers()),
        (NetworkListType.trueFriends, () => notifier.loadTrueFriends()),
      ];

      for (final (type, load) in cases) {
        repository.error = Exception('${type.name} failed');
        await load();

        final state = container.read(networkListsProvider);
        expect(state.isLoading[type], isFalse);
        expect(state.error[type], 'Exception: ${type.name} failed');
        expect(state.hasLoadedOnce[type], isTrue);
        repository.error = null;
      }
    });

    test('setListError records an error without changing other buckets', () {
      notifier.setListError(
        type: NetworkListType.blocked,
        errorMessage: 'blocked failed',
      );

      final state = container.read(networkListsProvider);
      expect(state.error[NetworkListType.blocked], 'blocked failed');
      expect(state.error[NetworkListType.followers], isNull);
    });
  });
}

class FakeSocialGraphRepository implements SocialGraphRepository {
  Object? error;
  List<SocialUserEntity> following = const [];
  List<SocialUserEntity> followers = const [];
  List<SocialUserEntity> myFollowing = const [];
  List<SocialUserEntity> myFollowers = const [];
  List<SocialUserEntity> suggestedUsers = const [];
  List<SocialUserEntity> suggestedArtists = const [];
  List<SocialUserEntity> blockedUsers = const [];
  List<SocialUserEntity> trueFriends = const [];

  (String, int, int)? lastUserFollowingArgs;
  (String, int, int)? lastUserFollowersArgs;
  (int, int)? lastMyFollowingArgs;
  (int, int)? lastMyFollowersArgs;
  (int, int)? lastSuggestedUsersArgs;
  (int, int)? lastSuggestedArtistsArgs;
  (int, int)? lastBlockedUsersArgs;
  (int, int)? lastTrueFriendsArgs;

  void _throwIfNeeded() {
    final value = error;
    if (value != null) throw value;
  }

  @override
  Future<List<SocialUserEntity>> getUserFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    _throwIfNeeded();
    lastUserFollowingArgs = (userId, page, limit);
    return following;
  }

  @override
  Future<List<SocialUserEntity>> getUserFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    _throwIfNeeded();
    lastUserFollowersArgs = (userId, page, limit);
    return followers;
  }

  @override
  Future<List<SocialUserEntity>> getMyFollowing({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    lastMyFollowingArgs = (page, limit);
    return myFollowing;
  }

  @override
  Future<List<SocialUserEntity>> getMyFollowers({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    lastMyFollowersArgs = (page, limit);
    return myFollowers;
  }

  @override
  Future<List<SocialUserEntity>> getSuggestedUsers({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    lastSuggestedUsersArgs = (page, limit);
    return suggestedUsers;
  }

  @override
  Future<List<SocialUserEntity>> getSuggestedArtists({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    lastSuggestedArtistsArgs = (page, limit);
    return suggestedArtists;
  }

  @override
  Future<List<SocialUserEntity>> getBlockedUsers({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    lastBlockedUsersArgs = (page, limit);
    return blockedUsers;
  }

  @override
  Future<List<SocialUserEntity>> getTrueFriends({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    lastTrueFriendsArgs = (page, limit);
    return trueFriends;
  }

  @override
  Future<void> followUser(String userId) async {}

  @override
  Future<void> unfollowUser(String userId) async {}

  @override
  Future<void> blockUser(String userId) async {}

  @override
  Future<void> unblockUser(String userId) async {}

  @override
  Future<SocialRelationEntity> getFollowStatus(String userId) async {
    return SocialRelationEntity(targetUserId: userId, isFollowing: false);
  }

  @override
  Future<bool> doesUserFollowMe(String otherUserId, String myUserId) async {
    return false;
  }
}
