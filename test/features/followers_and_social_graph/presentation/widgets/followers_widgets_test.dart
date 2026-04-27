import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/network_list_type.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_relation_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_user_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/repositories/social_graph_repository.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/social_graph_repository_provider.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/screens/blocked_users_screen.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/screens/network_lists_screen.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/widgets/network_lists_empty_state.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/widgets/network_lists_error_state.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/widgets/network_lists_true_friends_tile.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/widgets/relationship_button.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/widgets/suggested_user_item.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/widgets/suggested_users_section.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/widgets/user_social_tile.dart';

void main() {
  testWidgets('RelationshipButton exposes loading retry follow and block keys', (tester) async {
    final repository = FakeWidgetRepository();
    await tester.pumpWidget(_wrap(
      repository: repository,
      child: const RelationshipButton(userId: 'u1'),
    ));
    expect(find.byKey(const Key('relationship_loading_u1')), findsOneWidget);

    repository.error = Exception('status failed');
    await tester.pumpWidget(_wrap(
      repository: repository,
      child: const RelationshipButton(userId: 'u2'),
    ));
    await tester.pump();
    expect(find.byKey(const Key('relationship_retry_u2')), findsOneWidget);

    repository.error = null;
    await tester.pumpWidget(_wrap(
      repository: repository,
      child: const RelationshipButton(userId: 'u3', initialIsFollowing: false),
    ));
    expect(find.byKey(const Key('follow_button_u3')), findsOneWidget);
    expect(find.text('Follow'), findsOneWidget);
    await tester.tap(find.byKey(const Key('follow_button_u3')));
    await tester.pump();
    expect(repository.followed, contains('u3'));

    await tester.pumpWidget(_wrap(
      repository: repository,
      child: const RelationshipButton(
        userId: 'u4',
        initialIsBlocked: true,
        isBlockMode: true,
      ),
    ));
    expect(find.byKey(const Key('block_button_u4')), findsOneWidget);
    expect(find.text('Unblock'), findsOneWidget);
  });

  testWidgets('UserSocialTile renders user details action keys and notification key', (tester) async {
    final user = const SocialUserEntity(
      id: 'u5',
      username: 'certified_user',
      location: 'Cairo',
      followersCount: 9,
      isCertified: true,
      isFollowing: true,
      isNotificationEnabled: true,
    );

    var tapped = false;
    var notificationTapped = false;
    await tester.pumpWidget(_wrap(
      child: UserSocialTile(
        user: user,
        listType: NetworkListType.following,
        myId: 'me',
        onTap: () => tapped = true,
        onToggleNotifications: () => notificationTapped = true,
      ),
    ));

    expect(find.byKey(const Key('user_tile_u5')), findsOneWidget);
    expect(find.byKey(const Key('follow_button_u5')), findsOneWidget);
    expect(find.byKey(const Key('notification_button_u5')), findsOneWidget);
    expect(find.text('certified_user'), findsOneWidget);
    expect(find.text('Cairo'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);

    await tester.tap(find.text('certified_user'));
    await tester.tap(find.byKey(const Key('notification_button_u5')));
    expect(tapped, isTrue);
    expect(notificationTapped, isTrue);
  });

  testWidgets('UserSocialTile hides relationship controls for my own user', (tester) async {
    await tester.pumpWidget(_wrap(
      child: const UserSocialTile(
        user: SocialUserEntity(id: 'me', username: 'myself'),
        listType: NetworkListType.following,
        myId: 'me',
      ),
    ));

    expect(find.byKey(const Key('follow_button_me')), findsNothing);
    expect(find.byKey(const Key('notification_button_me')), findsNothing);
  });

  testWidgets('SuggestedUserItem has stable item and nested follow button keys', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(
      child: SuggestedUserItem(
        user: const SocialUserEntity(id: 'u6', username: 'suggested'),
        onTap: () => tapped = true,
      ),
    ));

    expect(find.byKey(const Key('suggested_user_item_u6')), findsOneWidget);
    expect(find.byKey(const Key('follow_button_u6')), findsOneWidget);
    await tester.tap(find.text('suggested'));
    expect(tapped, isTrue);
  });

  testWidgets('empty error and true-friends widgets render expected keys', (tester) async {
    var retried = false;
    var opened = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const Expanded(child: NetworkListsEmptyState()),
            Expanded(
              child: NetworkListsErrorState(onRetry: () => retried = true),
            ),
            NetworkListsTrueFriendsTile(onTap: () => opened = true),
          ],
        ),
      ),
    ));

    expect(find.text('No users found'), findsOneWidget);
    expect(find.byKey(const Key('retry_button')), findsOneWidget);
    expect(find.byKey(const Key('true_friends_list_tile')), findsOneWidget);

    await tester.tap(find.byKey(const Key('retry_button')));
    await tester.tap(find.byKey(const Key('true_friends_list_tile')));
    expect(retried, isTrue);
    expect(opened, isTrue);
  });

  testWidgets('SuggestedUsersSection loads suggestions and renders keyed horizontal list', (tester) async {
    final repository = FakeWidgetRepository()
      ..suggestedUsers = const [
        SocialUserEntity(id: 's1', username: 'suggested one'),
      ];

    await tester.pumpWidget(_wrap(
      repository: repository,
      child: const SuggestedUsersSection(listType: NetworkListType.suggestedUsers),
    ));

    expect(find.byKey(const Key('suggestedUsers_loading')), findsOneWidget);
    await tester.pump();

    expect(find.byKey(const Key('suggestedUsers_section')), findsOneWidget);
    expect(find.byKey(const Key('suggestedUsers_list')), findsOneWidget);
    expect(find.byKey(const ValueKey('suggestedUsers_suggested_item_s1')), findsOneWidget);
  });

  testWidgets('SuggestedUsersSection renders error and empty states with keys', (tester) async {
    final errorRepository = FakeWidgetRepository()..error = Exception('suggestions failed');
    await tester.pumpWidget(_wrap(
      repository: errorRepository,
      child: const SuggestedUsersSection(listType: NetworkListType.suggestedArtists),
    ));
    await tester.pump();

    expect(find.byKey(const Key('suggestedArtists_error')), findsOneWidget);
    expect(find.byKey(const Key('suggestedArtists_retry_button')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_wrap(
      repository: FakeWidgetRepository(),
      child: const SuggestedUsersSection(listType: NetworkListType.suggestedArtists),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('suggestedArtists_empty')), findsOneWidget);
  });

  testWidgets('NetworkListsScreen renders loading true-friends tile and user list keys', (tester) async {
    final repository = FakeWidgetRepository()
      ..myFollowing = const [
        SocialUserEntity(id: 'f1', username: 'following one', isFollowing: true),
      ];

    await tester.pumpWidget(_wrap(
      repository: repository,
      child: const NetworkListsScreen(listType: NetworkListType.following),
    ));

    expect(find.byKey(const Key('network_lists_screen_following')), findsOneWidget);
    expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
    await tester.pump();

    expect(find.byKey(const Key('following_refresh')), findsOneWidget);
    expect(find.byKey(const Key('following_list')), findsOneWidget);
    expect(find.byKey(const Key('true_friends_tile')), findsOneWidget);
    expect(find.byKey(const ValueKey('following_user_tile_f1')), findsOneWidget);
  });

  testWidgets('NetworkListsScreen renders error and empty states', (tester) async {
    final errorRepository = FakeWidgetRepository()..error = Exception('followers failed');
    await tester.pumpWidget(_wrap(
      repository: errorRepository,
      child: const NetworkListsScreen(listType: NetworkListType.followers),
    ));
    await tester.pump();

    expect(find.byKey(const Key('error_state')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_wrap(
      repository: FakeWidgetRepository(),
      child: const NetworkListsScreen(listType: NetworkListType.followers),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('empty_state')), findsOneWidget);
  });

  testWidgets('BlockedUsersScreen renders blocked users list and empty state keys', (tester) async {
    final repository = FakeWidgetRepository()
      ..blockedUsers = const [
        SocialUserEntity(id: 'b1', username: 'blocked one', isBlocked: true),
      ];

    await tester.pumpWidget(_wrap(
      repository: repository,
      child: const BlockedUsersScreen(),
    ));

    expect(find.byKey(const Key('blocked_users_screen')), findsOneWidget);
    expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
    await tester.pump();

    expect(find.byKey(const Key('blocked_users_refresh')), findsOneWidget);
    expect(find.byKey(const Key('blocked_users_list')), findsOneWidget);
    expect(find.byKey(const ValueKey('blocked_user_tile_b1')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_wrap(
      repository: FakeWidgetRepository(),
      child: const BlockedUsersScreen(),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('empty_state')), findsOneWidget);
  });
}

Widget _wrap({
  SocialGraphRepository? repository,
  required Widget child,
}) {
  return ProviderScope(
    overrides: [
      socialGraphRepositoryProvider.overrideWithValue(
        repository ?? FakeWidgetRepository(),
      ),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

class FakeWidgetRepository implements SocialGraphRepository {
  Object? error;
  final followed = <String>[];
  List<SocialUserEntity> myFollowing = const [];
  List<SocialUserEntity> myFollowers = const [];
  List<SocialUserEntity> userFollowing = const [];
  List<SocialUserEntity> userFollowers = const [];
  List<SocialUserEntity> suggestedUsers = const [];
  List<SocialUserEntity> suggestedArtists = const [];
  List<SocialUserEntity> blockedUsers = const [];
  List<SocialUserEntity> trueFriends = const [];

  void _throwIfNeeded() {
    final value = error;
    if (value != null) throw value;
  }

  @override
  Future<SocialRelationEntity> getFollowStatus(String userId) async {
    _throwIfNeeded();
    return SocialRelationEntity(targetUserId: userId, isFollowing: false);
  }

  @override
  Future<void> followUser(String userId) async {
    followed.add(userId);
  }

  @override
  Future<void> unfollowUser(String userId) async {}

  @override
  Future<void> blockUser(String userId) async {}

  @override
  Future<void> unblockUser(String userId) async {}

  @override
  Future<List<SocialUserEntity>> getUserFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    _throwIfNeeded();
    return userFollowers;
  }

  @override
  Future<List<SocialUserEntity>> getUserFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    _throwIfNeeded();
    return userFollowing;
  }

  @override
  Future<List<SocialUserEntity>> getMyFollowers({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    return myFollowers;
  }

  @override
  Future<List<SocialUserEntity>> getMyFollowing({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    return myFollowing;
  }

  @override
  Future<List<SocialUserEntity>> getBlockedUsers({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    return blockedUsers;
  }

  @override
  Future<List<SocialUserEntity>> getTrueFriends({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    return trueFriends;
  }

  @override
  Future<List<SocialUserEntity>> getSuggestedUsers({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    return suggestedUsers;
  }

  @override
  Future<List<SocialUserEntity>> getSuggestedArtists({int page = 1, int limit = 20}) async {
    _throwIfNeeded();
    return suggestedArtists;
  }
}
