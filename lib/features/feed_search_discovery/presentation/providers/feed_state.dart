import '../../domain/entities/feed_item_entity.dart';

class FeedState {
  final List<FeedItemEntity> followingItems;
  final List<FeedItemEntity> discoverItems;
  final bool isDiscoverLoading;
  final bool isFollowingLoading;
  final bool hasLoadedDiscover;
  final bool hasLoadedFollowing;
  final bool isPreviewing;
  final String? discoverError;
  final String? followingError;

  FeedState({
    this.followingItems = const [],
    this.discoverItems = const [],
    this.isDiscoverLoading = true,
    this.isFollowingLoading = false,
    this.hasLoadedDiscover = false,
    this.hasLoadedFollowing = false,
    this.isPreviewing = false,
    this.discoverError,
    this.followingError,
  });

  FeedState copyWith({
    List<FeedItemEntity>? followingItems,
    List<FeedItemEntity>? discoverItems,
    bool? isDiscoverLoading,
    bool? isFollowingLoading,
    bool? hasLoadedDiscover,
    bool? hasLoadedFollowing,
    bool? isPreviewing,
    String? discoverError,
    String? followingError,
  }) {
    return FeedState(
      followingItems: followingItems ?? this.followingItems,
      discoverItems: discoverItems ?? this.discoverItems,
      isDiscoverLoading: isDiscoverLoading ?? this.isDiscoverLoading,
      isFollowingLoading: isFollowingLoading ?? this.isFollowingLoading,
      hasLoadedDiscover: hasLoadedDiscover ?? this.hasLoadedDiscover,
      hasLoadedFollowing: hasLoadedFollowing ?? this.hasLoadedFollowing,
      isPreviewing: isPreviewing ?? this.isPreviewing,
      discoverError: discoverError,
      followingError: followingError,
    );
  }
}
