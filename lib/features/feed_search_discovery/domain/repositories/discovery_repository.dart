import '../entities/feed_item_entity.dart';
import '../entities/discovery_item_entity.dart';

abstract class DiscoveryRepository {
  Future<List<FeedItemEntity>> getFollowingFeed({
    int page = 1,
    int limit = 20,
    bool includeReposts = true,
    String? sinceTimestamp,
  });

  Future<List<DiscoveryItemEntity>> getDiscover({int page = 1, int limit = 20});
}
