import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/mock_network_lists_service.dart';
import '../../domain/entities/social_user_entity.dart';
import '../../domain/entities/network_lists_state.dart';

final mockNetworkListsServiceProvider = Provider<MockNetworkListsService>((ref){
  return MockNetworkListsService();
});

class NetworkListsNotifier extends Notifier<NetworkListsState>{
  @override 
  NetworkListsState build(){
    return const NetworkListsState();
  }

  Future<void> loadFollowingList({required String userID}) async {
    state = state.copyWith(
      isLoadingFollowing: true,
      error: null,
    );

    try {
      final service = ref.read(mockNetworkListsServiceProvider);
      final data = await service.fetchFollowingList(userID: userID);

      final followingUsers = data.map((user) {
        return SocialUserEntity(
          userID: user['id'] as String,
          userDisplayName: user['displayName'] as String,
          avatarUrl: user['avatarUrl'] as String,
          followersCount: user['followersCount'] as int,
          followingCount: 0,
          isFollowing: user['isFollowing'] as bool,
          isBlocked: false,
          isDeleted: false,
          isNotificationEnabled:
              user['isNotificationEnabled'] as bool? ?? false,
          isTrueFriend: false,
        );
      }).toList();

      state = state.copyWith(
        isLoadingFollowing: false,
        followingUsers: followingUsers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingFollowing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadFollowersList({required String userID}) async {
    state = state.copyWith(
      isLoadingFollowers: true,
      error: null,
    );

    try {
      final service = ref.read(mockNetworkListsServiceProvider);
      final data = await service.fetchFollowersList(userID: userID);

      final followerUsers = data.map((user) {
        return SocialUserEntity(
          userID: user['id'] as String,
          userDisplayName: user['displayName'] as String,
          avatarUrl: user['avatarUrl'] as String,
          followersCount: user['followersCount'] as int,
          followingCount: 0,
          isFollowing: user['isFollowing'] as bool,
          isBlocked: false,
          isDeleted: false,
          isNotificationEnabled: false,
          isTrueFriend: false,
        );
      }).toList();

      state = state.copyWith(
        isLoadingFollowers: false,
        followerUsers: followerUsers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingFollowers: false,
        error: e.toString(),
      );
    }
  }
}

final networkListsProvider =
    NotifierProvider<NetworkListsNotifier, NetworkListsState>(
  NetworkListsNotifier.new,
);