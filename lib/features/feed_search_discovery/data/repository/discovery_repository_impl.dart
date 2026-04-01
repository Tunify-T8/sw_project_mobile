import '../mappers/discover_item_mapper.dart';
import '../mappers/feed_item_mapper.dart';
import '../../domain/entities/discovery_item_entity.dart';
import '../../domain/entities/feed_item_entity.dart';

import '../api/discovery_api.dart';
import '../../domain/repositories/discovery_repository.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository{
  final DiscoveryApi api;

  DiscoveryRepositoryImpl(this.api);

  @override
  Future<List<FeedItemEntity>> getFollowingFeed({int page = 1, int limit = 20, bool includeReposts = true, String? sinceTimestamp}) async {
    final dtos = await api.getFollowingFeed(page: page, limit: limit, includeReposts: includeReposts, sinceTimestamp: sinceTimestamp);
    return dtos.items.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<DiscoveryItemEntity>> getDiscover({int page = 1, int limit = 20}) async {
    final dtos = await api.getDiscover(page: page, limit: limit);
    return dtos.items.map((dto) => dto.toEntity()).toList();
  }
}
