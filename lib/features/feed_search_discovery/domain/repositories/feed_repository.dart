import '../entities/feed_item_entity.dart';

abstract class FeedRepository {
  Future<List<FeedItemEntity>> getFollowingFeed({int page = 1, int limit = 20});

  Future<List<FeedItemEntity>> getDiscoverFeed({int page = 1, int limit = 20});
}