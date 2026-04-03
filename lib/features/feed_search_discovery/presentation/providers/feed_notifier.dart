import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feed_provider.dart';
import 'feed_state.dart';
import '../../domain/entities/feed_tab_type.dart';

final feedNotifierProvider = NotifierProvider<FeedNotifier, FeedState>(
  FeedNotifier.new,
);

class FeedNotifier extends Notifier<FeedState> {
  @override
  FeedState build() => FeedState();

  Future<void> loadFeed({
    required FeedType tab,
    int page = 1,
    int limit = 20,
  }) async {
    if (tab == FeedType.discover) {
      state = state.copyWith(
        isDiscoverLoading: true,
        discoverError: null,
        followingError: state.followingError,
      );
    } else {
      state = state.copyWith(
        isFollowingLoading: true,
        followingError: null,
        discoverError: state.discoverError,
      );
    }

    try {
      final repository = ref.read(feedRepositoryProvider);

      if (tab == FeedType.discover) {
        final items = await repository.getDiscoverFeed(page: page, limit: limit);
        state = state.copyWith(
          discoverItems: items,
          isDiscoverLoading: false,
          hasLoadedDiscover: true,
          discoverError: null,
          followingError: state.followingError,
        );
      } else {
        final items = await repository.getFollowingFeed(page: page, limit: limit);
        state = state.copyWith(
          followingItems: items,
          isFollowingLoading: false,
          hasLoadedFollowing: true,
          followingError: null,
          discoverError: state.discoverError,
        );
      }
    } catch (e) {
      if (tab == FeedType.discover) {
        state = state.copyWith(
          isDiscoverLoading: false,
          hasLoadedDiscover: true,
          discoverError: e.toString(),
          followingError: state.followingError,
        );
      } else {
        state = state.copyWith(
          isFollowingLoading: false,
          hasLoadedFollowing: true,
          followingError: e.toString(),
          discoverError: state.discoverError,
        );
      }
    }
  }

  Future<void> refreshFeed({
    required FeedType tab,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final repository = ref.read(feedRepositoryProvider);

      if (tab == FeedType.discover) {
        final items = await repository.getDiscoverFeed(page: page, limit: limit);
        state = state.copyWith(
          discoverItems: items,
          discoverError: null,
          followingError: state.followingError,
        );
      } else {
        final items = await repository.getFollowingFeed(page: page, limit: limit);
        state = state.copyWith(
          followingItems: items,
          followingError: null,
          discoverError: state.discoverError,
        );
      }
    } catch (e) {
      if (tab == FeedType.discover) {
        state = state.copyWith(
          discoverError: e.toString(),
          followingError: state.followingError,
        );
      } else {
        state = state.copyWith(
          followingError: e.toString(),
          discoverError: state.discoverError,
        );
      }
    }
  }

  void togglePreview() {
    state = state.copyWith(isPreviewing: !state.isPreviewing);
  }
}
