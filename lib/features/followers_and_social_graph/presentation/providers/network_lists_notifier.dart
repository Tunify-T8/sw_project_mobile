import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/network_list_type.dart';

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
    state = state.updateListState(
      type: NetworkListType.following,
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final following = await repository.getUserFollowing(
        userId: userId,
        page: page,
        limit: limit,
      );

      state = state.updateListState(
        type: NetworkListType.following,
        users: following,
        isLoading: false,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.updateListState(
        type: NetworkListType.following,
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
    state = state.updateListState(
      type: NetworkListType.followers,
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final followers = await repository.getUserFollowers(
        userId: userId,
        page: page,
        limit: limit,
      );

      state = state.updateListState(
        type: NetworkListType.followers,
        users: followers,
        isLoading: false,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.updateListState(
        type: NetworkListType.followers,
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  Future<void> loadMyFollowing({int page = 1, int limit = 20}) async {
    state = state.updateListState(
      type: NetworkListType.following,
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final following = await repository.getMyFollowing(
        page: page,
        limit: limit,
      );

      state = state.updateListState(
        type: NetworkListType.following,
        users: following,
        isLoading: false,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.updateListState(
        type: NetworkListType.following,
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  Future<void> loadMyFollowers({int page = 1, int limit = 20}) async {
    state = state.updateListState(
      type: NetworkListType.followers,
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final followers = await repository.getMyFollowers(
        page: page,
        limit: limit,
      );

      state = state.updateListState(
        type: NetworkListType.followers,
        users: followers,
        isLoading: false,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.updateListState(
        type: NetworkListType.followers,
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  Future<void> loadSuggestedUsers({int page = 1, int limit = 20}) async {
    state = state.updateListState(
      type: NetworkListType.suggestedUsers,
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final suggestedUsers = await repository.getSuggestedUsers(
        page: page,
        limit: limit,
      );

      state = state.updateListState(
        type: NetworkListType.suggestedUsers,
        users: suggestedUsers,
        isLoading: false,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.updateListState(
        type: NetworkListType.suggestedUsers,
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  Future<void> loadSuggestedArtists({int page = 1, int limit = 20}) async {
    state = state.updateListState(
      type: NetworkListType.suggestedArtists,
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final suggestedUsers = await repository.getSuggestedArtists(
        page: page,
        limit: limit,
      );

      state = state.updateListState(
        type: NetworkListType.suggestedArtists,
        users: suggestedUsers,
        isLoading: false,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.updateListState(
        type: NetworkListType.suggestedArtists,
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  Future<void> loadBlockedUsers({int page = 1, int limit = 20}) async {
    state = state.updateListState(
      type: NetworkListType.blocked,
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final blockedUsers = await repository.getBlockedUsers(
        page: page,
        limit: limit,
      );

      state = state.updateListState(
        type: NetworkListType.blocked,
        users: blockedUsers,
        isLoading: false,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.updateListState(
        type: NetworkListType.blocked,
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  Future<void> loadTrueFriends({int page = 1, int limit = 20}) async {
    state = state.updateListState(
      type: NetworkListType.trueFriends,
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(socialGraphRepositoryProvider);
      final trueFriends = await repository.getTrueFriends(
        page: page,
        limit: limit,
      );

      state = state.updateListState(
        type: NetworkListType.trueFriends,
        users: trueFriends,
        isLoading: false,
        hasLoadedOnce: true,
        error: null,
      );
    } catch (e) {
      state = state.updateListState(
        type: NetworkListType.trueFriends,
        isLoading: false,
        error: e.toString(),
        hasLoadedOnce: true,
      );
    }
  }

  void setListError({
    required NetworkListType type,
    required String errorMessage,
  }) {
    state = state.updateListState(type: type, error: errorMessage);
  }
}
