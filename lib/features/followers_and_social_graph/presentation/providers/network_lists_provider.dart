import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_lists_state.dart';
import 'social_graph_repository_provider.dart';

class NetworkListsNotifier extends Notifier<NetworkListsState> {
  @override
  NetworkListsState build() {
    return const NetworkListsState();
  }

  Future<void> loadFollowingList({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(
      isLoadingFollowing: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final followingUsers = await repository.getFollowing(
        userId: userId,
        page: page,
        limit: limit,
      );

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

  Future<void> loadFollowersList({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(
      isLoadingFollowers: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final followersUsers = await repository.getFollowers(
        userId: userId,
        page: page,
        limit: limit,
      );

      state = state.copyWith(
        isLoadingFollowers: false,
        followersUsers: followersUsers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingFollowers: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadSuggestedUsers({
    int page = 1,
    int limit = 20,
    String? genre,
  }) async {
    state = state.copyWith(
      isLoadingSuggested: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final suggestedUsers = await repository.getSuggestedUsers(
        page: page,
        limit: limit,
        genre: genre,
      );

      state = state.copyWith(
        isLoadingSuggested: false,
        suggestedUsers: suggestedUsers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSuggested: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadBlockedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(
      isLoadingBlocked: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final blockedUsers = await repository.getBlockedUsers(
        page: page,
        limit: limit,
      );

      state = state.copyWith(
        isLoadingBlocked: false,
        blockedUsers: blockedUsers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingBlocked: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMutualUsers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(
      isLoadingMutual: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final mutualUsers = await repository.getMutualFriends(
        userId: userId,
        page: page,
        limit: limit,
      );

      state = state.copyWith(
        isLoadingMutual: false,
        mutualUsers: mutualUsers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMutual: false,
        error: e.toString(),
      );
    }
  }

  Future<void> followUser(String userId) async {
    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      await repository.followUser(userId);

      state = state.copyWith(
        followingUsers: [
          ...state.followingUsers,
          ...state.followersUsers
              .where((user) => user.id == userId && !user.isFollowing)
              .map((user) => user.copyWith(isFollowing: true)),
        ],
        followersUsers: state.followersUsers.map((user) {
          if (user.id == userId) {
            return user.copyWith(
              isFollowing: true,
              followersCount: (user.followersCount ?? 0) + 1,
            );
          }
          return user;
        }).toList(),
        suggestedUsers: state.suggestedUsers.map((user) {
          if (user.id == userId) {
            return user.copyWith(
              isFollowing: true,
              followersCount: (user.followersCount ?? 0) + 1,
            );
          }
          return user;
        }).toList(),
        mutualUsers: state.mutualUsers.map((user) {
          if (user.id == userId) {
            return user.copyWith(isFollowing: true);
          }
          return user;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      await repository.unfollowUser(userId);

      state = state.copyWith(
        followingUsers:
            state.followingUsers.where((user) => user.id != userId).toList(),
        followersUsers: state.followersUsers.map((user) {
          if (user.id == userId) {
            return user.copyWith(
              isFollowing: false,
              followersCount: ((user.followersCount ?? 1) - 1).clamp(0, 1 << 30),
            );
          }
          return user;
        }).toList(),
        suggestedUsers: state.suggestedUsers.map((user) {
          if (user.id == userId) {
            return user.copyWith(
              isFollowing: false,
              followersCount: ((user.followersCount ?? 1) - 1).clamp(0, 1 << 30),
            );
          }
          return user;
        }).toList(),
        mutualUsers: state.mutualUsers.map((user) {
          if (user.id == userId) {
            return user.copyWith(isFollowing: false);
          }
          return user;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      await repository.blockUser(userId);

      final blockedUser = [
        ...state.followersUsers,
        ...state.followingUsers,
        ...state.suggestedUsers,
        ...state.mutualUsers,
      ].where((user) => user.id == userId).cast().toList();

      state = state.copyWith(
        followersUsers:
            state.followersUsers.where((user) => user.id != userId).toList(),
        followingUsers:
            state.followingUsers.where((user) => user.id != userId).toList(),
        suggestedUsers:
            state.suggestedUsers.where((user) => user.id != userId).toList(),
        mutualUsers:
            state.mutualUsers.where((user) => user.id != userId).toList(),
        blockedUsers: [
          ...state.blockedUsers,
          ...blockedUser.map(
            (user) => user.copyWith(
              isFollowing: false,
              blockedAt: DateTime.now().toIso8601String(),
            ),
          ),
        ],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      await repository.unblockUser(userId);

      state = state.copyWith(
        blockedUsers:
            state.blockedUsers.where((user) => user.id != userId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void toggleNotifications(String userId) {
  state = state.copyWith(
    followingUsers: state.followingUsers.map((user) {
      if (user.id == userId) {
        return user.copyWith(
          isNotificationEnabled: !user.isNotificationEnabled,
        );
      }
      return user;
    }).toList(),
  );
}
}

final networkListsProvider =
    NotifierProvider<NetworkListsNotifier, NetworkListsState>(
  NetworkListsNotifier.new,
);