import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feed_provider.dart';
import 'feed_state.dart';

final feedNotifierProvider = NotifierProvider<FeedNotifier, FeedState>(
  FeedNotifier.new,
);

class FeedNotifier extends Notifier<FeedState> {
  @override
  FeedState build() {
    return FeedState();
  }

  Future<void> loadFollowingFeed({int page = 1, int limit = 20}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(feedRepositoryProvider);
      final followingFeedList = await repository.getFollowingFeed(
        page: page,
        limit: limit,
      );

      state = state.copyWith(
        feedItems: followingFeedList,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshFeed({int page = 1, int limit = 20}) async {
    try {
      final repository = ref.read(feedRepositoryProvider);
      final followingFeedList = await repository.getFollowingFeed(
        page: page,
        limit: limit,
      );

      state = state.copyWith(
        feedItems: followingFeedList,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }


  void togglePreview() {
    state = state.copyWith(
      isPreviewing: !state.isPreviewing,
    );
  }
}