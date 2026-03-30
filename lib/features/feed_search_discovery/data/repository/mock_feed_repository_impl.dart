import '../../domain/repositories/feed_repository.dart';
import '../../domain/entities/feed_item_entity.dart';
import '../services/mock_feed_service.dart';

class MockFeedRepositoryImpl implements FeedRepository {
  final MockFeedService mockFeedService;

  MockFeedRepositoryImpl(this.mockFeedService);

  @override
  Future<List<FeedItemEntity>> getFollowingFeed({int page = 1, int limit = 20}) async {
    return await mockFeedService.getFollowingFeed();
  }
}