import '../../domain/entities/feed_item_entity.dart';
import '../../domain/entities/discovery_item_entity.dart';

class FeedState {
  final List<FeedItemEntity> feedItems;
  final List<DiscoveryItemEntity> discoverItems;
  final bool isLoading;
  final bool isPreviewing;
  final String? error;

  FeedState({
    this.feedItems = const [],
    this.discoverItems = const [],
    this.isLoading = true,
    this.isPreviewing = false,
    this.error,
  });

  FeedState copyWith({
    List<FeedItemEntity>? feedItems,
    List<DiscoveryItemEntity>? discoverItems,
    bool? isLoading,
    bool? isPreviewing,
    String? error,
  }) {
    return FeedState(
      feedItems: feedItems ?? this.feedItems,
      discoverItems: discoverItems ?? this.discoverItems,
      isLoading: isLoading ?? this.isLoading,
      isPreviewing: isPreviewing ?? this.isPreviewing,
      error: error,
    );
  }
}
