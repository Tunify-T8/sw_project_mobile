import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_user_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/repositories/social_graph_repository.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/network_lists_provider.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/social_graph_repository_provider.dart';

import 'network_lists_provider_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SocialGraphRepository>()])
void main() {
  late MockSocialGraphRepository repository;
  late ProviderContainer container;
  late NetworkListsNotifier notifier;

  SocialUserEntity user(
    String id, {
    bool isFollowing = false,
    bool isBlocked = false,
  }) {
    return SocialUserEntity(
      id: id,
      username: 'user_$id',
      isFollowing: isFollowing,
      isBlocked: isBlocked,
    );
  }

  setUp(() {
    repository = MockSocialGraphRepository();
    container = ProviderContainer(
      overrides: [
        socialGraphRepositoryProvider.overrideWithValue(repository),
      ],
    );
    notifier = container.read(networkListsProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('initial state', () {
    test('starts with defaults', () {
      final state = container.read(networkListsProvider);

      expect(state.following, isEmpty);
      expect(state.followers, isEmpty);
      expect(state.suggestedUsers, isEmpty);
      expect(state.blockedUsers, isEmpty);
      expect(state.mutualFriends, isEmpty);
      expect(state.isLoading, isTrue);
      expect(state.error, isNull);
      expect(state.hasLoadedOnce, isFalse);
    });
  });

  group('loadFollowingList', () {
    test('loads following users and passes custom arguments to repository', () async {
      final users = [user('1', isFollowing: true), user('2')];
      when(
        repository.getFollowing(
          userId: 'target-user',
          page: 3,
          limit: 15,
        ),
      ).thenAnswer((_) async => users);

      await notifier.loadFollowingList(
        userId: 'target-user',
        page: 3,
        limit: 15,
      );

      final state = container.read(networkListsProvider);
      expect(state.following, users);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.hasLoadedOnce, isTrue);
      verify(
        repository.getFollowing(
          userId: 'target-user',
          page: 3,
          limit: 15,
        ),
      ).called(1);
    });

    test('stores an error when loading following users fails', () async {
      when(
        repository.getFollowing(
          userId: 'target-user',
          page: 1,
          limit: 20,
        ),
      ).thenThrow(Exception('following failed'));

      await notifier.loadFollowingList(userId: 'target-user');

      final state = container.read(networkListsProvider);
      expect(state.following, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, 'Exception: following failed');
      expect(state.hasLoadedOnce, isTrue);
      verify(
        repository.getFollowing(
          userId: 'target-user',
          page: 1,
          limit: 20,
        ),
      ).called(1);
    });
  });

  group('loadFollowersList', () {
    test('loads followers with default paging values', () async {
      final users = [user('3')];
      when(
        repository.getFollowers(
          userId: 'listener',
          page: 1,
          limit: 20,
        ),
      ).thenAnswer((_) async => users);

      await notifier.loadFollowersList(userId: 'listener');

      final state = container.read(networkListsProvider);
      expect(state.followers, users);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.hasLoadedOnce, isTrue);
      verify(
        repository.getFollowers(
          userId: 'listener',
          page: 1,
          limit: 20,
        ),
      ).called(1);
    });

    test('stores an error when loading followers fails', () async {
      when(
        repository.getFollowers(
          userId: 'listener',
          page: 2,
          limit: 10,
        ),
      ).thenThrow(StateError('followers failed'));

      await notifier.loadFollowersList(
        userId: 'listener',
        page: 2,
        limit: 10,
      );

      final state = container.read(networkListsProvider);
      expect(state.followers, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, 'Bad state: followers failed');
      expect(state.hasLoadedOnce, isTrue);
      verify(
        repository.getFollowers(
          userId: 'listener',
          page: 2,
          limit: 10,
        ),
      ).called(1);
    });
  });

  group('loadSuggestedUsers', () {
    test('loads suggested users and forwards genre filter', () async {
      final users = [user('4'), user('5', isFollowing: true)];
      when(
        repository.getSuggestedUsers(
          page: 4,
          limit: 8,
          genre: 'rock',
        ),
      ).thenAnswer((_) async => users);

      await notifier.loadSuggestedUsers(
        page: 4,
        limit: 8,
        genre: 'rock',
      );

      final state = container.read(networkListsProvider);
      expect(state.suggestedUsers, users);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.hasLoadedOnce, isTrue);
      verify(
        repository.getSuggestedUsers(
          page: 4,
          limit: 8,
          genre: 'rock',
        ),
      ).called(1);
    });

    test('stores an error when suggested users loading fails', () async {
      when(
        repository.getSuggestedUsers(
          page: 1,
          limit: 20,
          genre: null,
        ),
      ).thenThrow(Exception('suggested failed'));

      await notifier.loadSuggestedUsers();

      final state = container.read(networkListsProvider);
      expect(state.suggestedUsers, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, 'Exception: suggested failed');
      expect(state.hasLoadedOnce, isTrue);
      verify(
        repository.getSuggestedUsers(
          page: 1,
          limit: 20,
          genre: null,
        ),
      ).called(1);
    });
  });

  group('loadBlockedUsers', () {
    test('loads blocked users and passes paging arguments', () async {
      final users = [user('6', isBlocked: true)];
      when(
        repository.getBlockedUsers(
          page: 2,
          limit: 5,
        ),
      ).thenAnswer((_) async => users);

      await notifier.loadBlockedUsers(page: 2, limit: 5);

      final state = container.read(networkListsProvider);
      expect(state.blockedUsers, users);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.hasLoadedOnce, isTrue);
      verify(
        repository.getBlockedUsers(
          page: 2,
          limit: 5,
        ),
      ).called(1);
    });

    test('stores an error when blocked users loading fails', () async {
      when(
        repository.getBlockedUsers(
          page: 1,
          limit: 20,
        ),
      ).thenThrow(Exception('blocked failed'));

      await notifier.loadBlockedUsers();

      final state = container.read(networkListsProvider);
      expect(state.blockedUsers, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, 'Exception: blocked failed');
      expect(state.hasLoadedOnce, isTrue);
      verify(
        repository.getBlockedUsers(
          page: 1,
          limit: 20,
        ),
      ).called(1);
    });
  });

  group('loadMutualFriends', () {
    test('loads mutual friends and passes required arguments', () async {
      final users = [user('7'), user('8')];
      when(
        repository.getMutualFriends(
          userId: 'artist',
          page: 6,
          limit: 9,
        ),
      ).thenAnswer((_) async => users);

      await notifier.loadMutualFriends(
        userId: 'artist',
        page: 6,
        limit: 9,
      );

      final state = container.read(networkListsProvider);
      expect(state.mutualFriends, users);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.hasLoadedOnce, isTrue);
      verify(
        repository.getMutualFriends(
          userId: 'artist',
          page: 6,
          limit: 9,
        ),
      ).called(1);
    });

    test('stores an error when mutual friends loading fails', () async {
      when(
        repository.getMutualFriends(
          userId: 'artist',
          page: 1,
          limit: 20,
        ),
      ).thenThrow(Exception('mutual failed'));

      await notifier.loadMutualFriends(userId: 'artist');

      final state = container.read(networkListsProvider);
      expect(state.mutualFriends, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, 'Exception: mutual failed');
      expect(state.hasLoadedOnce, isTrue);
      verify(
        repository.getMutualFriends(
          userId: 'artist',
          page: 1,
          limit: 20,
        ),
      ).called(1);
    });
  });

  group('state mutation helpers', () {
    test('updateFollowStatus updates matching user across all lists only', () async {
      final target = user('shared-user');
      final untouched = user('other-user', isFollowing: true);

      when(
        repository.getFollowers(
          userId: 'followers-source',
          page: 1,
          limit: 20,
        ),
      ).thenAnswer((_) async => [target, untouched]);
      when(
        repository.getFollowing(
          userId: 'following-source',
          page: 1,
          limit: 20,
        ),
      ).thenAnswer((_) async => [target]);
      when(
        repository.getSuggestedUsers(
          page: 1,
          limit: 20,
          genre: null,
        ),
      ).thenAnswer((_) async => [target]);
      when(
        repository.getBlockedUsers(
          page: 1,
          limit: 20,
        ),
      ).thenAnswer((_) async => [target.copyWith(isBlocked: true)]);
      when(
        repository.getMutualFriends(
          userId: 'mutual-source',
          page: 1,
          limit: 20,
        ),
      ).thenAnswer((_) async => [target]);

      await notifier.loadFollowersList(userId: 'followers-source');
      await notifier.loadFollowingList(userId: 'following-source');
      await notifier.loadSuggestedUsers();
      await notifier.loadBlockedUsers();
      await notifier.loadMutualFriends(userId: 'mutual-source');

      notifier.updateFollowStatus(
        userId: 'shared-user',
        isFollowing: true,
      );

      final state = container.read(networkListsProvider);
      expect(state.followers.first.isFollowing, isTrue);
      expect(state.followers.last.isFollowing, isTrue);
      expect(state.following.first.isFollowing, isTrue);
      expect(state.suggestedUsers.first.isFollowing, isTrue);
      expect(state.blockedUsers.first.isFollowing, isTrue);
      expect(state.mutualFriends.first.isFollowing, isTrue);
    });

    test('updateBlockStatus updates matching user across all lists only', () async {
      final target = user('shared-user');
      final untouched = user('other-user');

      when(
        repository.getFollowers(
          userId: 'followers-source',
          page: 1,
          limit: 20,
        ),
      ).thenAnswer((_) async => [target, untouched]);
      when(
        repository.getFollowing(
          userId: 'following-source',
          page: 1,
          limit: 20,
        ),
      ).thenAnswer((_) async => [target]);
      when(
        repository.getSuggestedUsers(
          page: 1,
          limit: 20,
          genre: null,
        ),
      ).thenAnswer((_) async => [target]);
      when(
        repository.getBlockedUsers(
          page: 1,
          limit: 20,
        ),
      ).thenAnswer((_) async => [target]);
      when(
        repository.getMutualFriends(
          userId: 'mutual-source',
          page: 1,
          limit: 20,
        ),
      ).thenAnswer((_) async => [target]);

      await notifier.loadFollowersList(userId: 'followers-source');
      await notifier.loadFollowingList(userId: 'following-source');
      await notifier.loadSuggestedUsers();
      await notifier.loadBlockedUsers();
      await notifier.loadMutualFriends(userId: 'mutual-source');

      notifier.updateBlockStatus(
        userId: 'shared-user',
        isBlocked: true,
      );

      final state = container.read(networkListsProvider);
      expect(state.followers.first.isBlocked, isTrue);
      expect(state.followers.last.isBlocked, isFalse);
      expect(state.following.first.isBlocked, isTrue);
      expect(state.suggestedUsers.first.isBlocked, isTrue);
      expect(state.blockedUsers.first.isBlocked, isTrue);
      expect(state.mutualFriends.first.isBlocked, isTrue);
    });

    test('setError and clearError update the error field', () {
      notifier.setError('temporary problem');
      expect(container.read(networkListsProvider).error, 'temporary problem');

      notifier.clearError();
      expect(container.read(networkListsProvider).error, isNull);
    });
  });
}
