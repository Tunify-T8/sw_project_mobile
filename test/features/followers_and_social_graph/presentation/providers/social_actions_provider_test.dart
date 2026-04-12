import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/network_list_type.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_user_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/repositories/social_graph_repository.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/network_lists_notifier.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/relationship_status_notifier.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/social_graph_repository_provider.dart';

import 'social_actions_provider_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SocialGraphRepository>(),
])
void main() {
  late MockSocialGraphRepository repository;
  late ProviderContainer container;
  late TestNetworkListsNotifier listsNotifier;
  late SocialActionsNotifier notifier;

  setUp(() {
    repository = MockSocialGraphRepository();
    listsNotifier = TestNetworkListsNotifier();
    container = ProviderContainer(
      overrides: [
        socialGraphRepositoryProvider.overrideWithValue(repository),
        networkListsProvider.overrideWith(() => listsNotifier),
      ],
    );
    notifier = container.read(socialActionsProvider);
    container.read(networkListsProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('toggleFollow', () {
    test(
      'follows a user and updates follow status when user is not followed',
      () async {
      const user = SocialUserEntity(
        id: 'user-1',
        username: 'alice',
      );
      when(repository.followUser('user-1')).thenAnswer((_) async {});

      await notifier.toggleFollow(user);

      verify(repository.followUser('user-1')).called(1);
      verifyNever(repository.unfollowUser('user-1'));
      expect(listsNotifier.followUpdateCalls, 1);
      expect(listsNotifier.lastFollowUpdatedUserId, 'user-1');
      expect(listsNotifier.lastIsFollowing, isTrue);
      expect(listsNotifier.errorCalls, 0);
    });

    test(
      'unfollows a user and updates follow status when user is already followed',
      () async {
      const user = SocialUserEntity(
        id: 'user-2',
        username: 'bob',
        isFollowing: true,
      );
      when(repository.unfollowUser('user-2')).thenAnswer((_) async {});

      await notifier.toggleFollow(user);

      verify(repository.unfollowUser('user-2')).called(1);
      verifyNever(repository.followUser('user-2'));
      expect(listsNotifier.followUpdateCalls, 1);
      expect(listsNotifier.lastFollowUpdatedUserId, 'user-2');
      expect(listsNotifier.lastIsFollowing, isFalse);
      expect(listsNotifier.errorCalls, 0);
    });

    test('reports an error and does not update state when follow fails', () async {
      const user = SocialUserEntity(
        id: 'user-3',
        username: 'charlie',
      );
      when(repository.followUser('user-3')).thenThrow(StateError('follow failed'));

      await notifier.toggleFollow(user);

      verify(repository.followUser('user-3')).called(1);
      expect(listsNotifier.followUpdateCalls, 0);
      expect(listsNotifier.errorCalls, 1);
      expect(listsNotifier.lastErrorMessage, 'Bad state: follow failed');
    });
  });

  group('toggleBlock', () {
    test(
      'blocks a user and updates block status when user is not blocked',
      () async {
      const user = SocialUserEntity(
        id: 'user-4',
        username: 'dina',
      );
      when(repository.blockUser('user-4')).thenAnswer((_) async {});

      await notifier.toggleBlock(
        user: user,
        listType: NetworkListType.suggestedUsers,
      );

      verify(repository.blockUser('user-4')).called(1);
      verifyNever(repository.unblockUser('user-4'));
      expect(listsNotifier.blockUpdateCalls, 1);
      expect(listsNotifier.lastBlockUpdatedUserId, 'user-4');
      expect(listsNotifier.lastIsBlocked, isTrue);
      expect(listsNotifier.errorCalls, 0);
    });

    test(
      'unblocks a user and updates block status when user is already blocked',
      () async {
      const user = SocialUserEntity(
        id: 'user-5',
        username: 'eva',
        isBlocked: true,
      );
      when(repository.unblockUser('user-5')).thenAnswer((_) async {});

      await notifier.toggleBlock(
        user: user,
        listType: NetworkListType.blocked,
      );

      verify(repository.unblockUser('user-5')).called(1);
      verifyNever(repository.blockUser('user-5'));
      expect(listsNotifier.blockUpdateCalls, 1);
      expect(listsNotifier.lastBlockUpdatedUserId, 'user-5');
      expect(listsNotifier.lastIsBlocked, isFalse);
      expect(listsNotifier.errorCalls, 0);
    });

    test(
      'reports an error and does not update state when block action fails',
      () async {
      const user = SocialUserEntity(
        id: 'user-6',
        username: 'fady',
        isBlocked: true,
      );
      when(repository.unblockUser('user-6')).thenThrow(Exception('unblock failed'));

      await notifier.toggleBlock(
        user: user,
        listType: NetworkListType.followers,
      );

      verify(repository.unblockUser('user-6')).called(1);
      expect(listsNotifier.blockUpdateCalls, 0);
      expect(listsNotifier.errorCalls, 1);
      expect(listsNotifier.lastErrorMessage, 'Exception: unblock failed');
    });
  });
}

class TestNetworkListsNotifier extends NetworkListsNotifier {
  int followUpdateCalls = 0;
  int blockUpdateCalls = 0;
  int errorCalls = 0;
  String? lastFollowUpdatedUserId;
  bool? lastIsFollowing;
  String? lastBlockUpdatedUserId;
  bool? lastIsBlocked;
  String? lastErrorMessage;

  @override
  void updateFollowStatus({
    required String userId,
    required bool isFollowing,
  }) {
    followUpdateCalls++;
    lastFollowUpdatedUserId = userId;
    lastIsFollowing = isFollowing;
    super.updateFollowStatus(userId: userId, isFollowing: isFollowing);
  }

  @override
  void updateBlockStatus({
    required String userId,
    required bool isBlocked,
  }) {
    blockUpdateCalls++;
    lastBlockUpdatedUserId = userId;
    lastIsBlocked = isBlocked;
    super.updateBlockStatus(userId: userId, isBlocked: isBlocked);
  }

  @override
  void setError(String errorMessage) {
    errorCalls++;
    lastErrorMessage = errorMessage;
    super.setError(errorMessage);
  }
}
