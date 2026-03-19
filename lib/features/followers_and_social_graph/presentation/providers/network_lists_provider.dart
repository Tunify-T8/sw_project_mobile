import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_lists_state.dart';
import 'social_graph_repository_provider.dart';

final networkListsProvider =
    NotifierProvider<NetworkListsNotifier, NetworkListsState>(
  NetworkListsNotifier.new,
);

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
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final following = await repository.getFollowing(
        userId: userId,
        page: page,
        limit: limit,
      );

      state = state.copyWith(
        isLoading: false,
        following: following,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  Future<void> loadFollowersList({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final followers = await repository.getFollowers(
        userId: userId,
        page: page,
        limit: limit,
      );

      state = state.copyWith(
        isLoading: false,
        followers: followers,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  Future<void> loadSuggestedUsers({
    int page = 1,
    int limit = 20,
    String? genre,
  }) async {
    state = state.copyWith(
      isLoading: true,
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
        isLoading: false,
        suggestedUsers: suggestedUsers,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  Future<void> loadBlockedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final blockedUsers = await repository.getBlockedUsers(
        page: page,
        limit: limit,
      );

      state = state.copyWith(
        isLoading: false,
        blockedUsers: blockedUsers,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  Future<void> loadMutualFriends({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final mutualFriends = await repository.getMutualFriends(
        userId: userId,
        page: page,
        limit: limit,
      );

      state = state.copyWith(
        isLoading: false,
        mutualFriends: mutualFriends,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  void updateFollowStatus({
  required String userId,
  required bool isFollowing,
}) {
  state = state.copyWith(
    followers: state.followers
        .map(
          (user) => user.id == userId
              ? user.copyWith(isFollowing: isFollowing)
              : user,
        )
        .toList(),
    following: state.following
        .map(
          (user) => user.id == userId
              ? user.copyWith(isFollowing: isFollowing)
              : user,
        )
        .toList(),
    suggestedUsers: state.suggestedUsers
        .map(
          (user) => user.id == userId
              ? user.copyWith(isFollowing: isFollowing)
              : user,
        )
        .toList(),
    mutualFriends: state.mutualFriends
        .map(
          (user) => user.id == userId
              ? user.copyWith(isFollowing: isFollowing)
              : user,
        )
        .toList(),
    blockedUsers: state.blockedUsers
        .map(
          (user) => user.id == userId
              ? user.copyWith(isFollowing: isFollowing)
              : user,
        )
        .toList(),
  );
}

void updateBlockStatus({
  required String userId,
  required bool isBlocked,
}) {
  state = state.copyWith(
    followers: state.followers
        .map(
          (user) =>
              user.id == userId ? user.copyWith(isBlocked: isBlocked) : user,
        )
        .toList(),
    following: state.following
        .map(
          (user) =>
              user.id == userId ? user.copyWith(isBlocked: isBlocked) : user,
        )
        .toList(),
    suggestedUsers: state.suggestedUsers
        .map(
          (user) =>
              user.id == userId ? user.copyWith(isBlocked: isBlocked) : user,
        )
        .toList(),
    mutualFriends: state.mutualFriends
        .map(
          (user) =>
              user.id == userId ? user.copyWith(isBlocked: isBlocked) : user,
        )
        .toList(),
    blockedUsers: state.blockedUsers
        .map(
          (user) =>
              user.id == userId ? user.copyWith(isBlocked: isBlocked) : user,
        )
        .toList(),
  );
}

void setError(String errorMessage) {
  state = state.copyWith(error: errorMessage);
}

  void clearError() {
    state = state.copyWith(error: null);
  }
}