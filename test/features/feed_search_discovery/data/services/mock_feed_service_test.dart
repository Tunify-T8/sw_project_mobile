import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/data/services/mock_feed_service.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_source.dart';

void main() {
  late MockFeedService service;

  setUp(() {
    service = MockFeedService();
  });

  test('getFollowingFeed returns seeded following items', () async {
    final result = await service.getFollowingFeed();

    expect(result, hasLength(2));
    expect(result.first.actor.username, 'Drake');
    expect(result.first.source, FeedItemSource.post);
    expect(result.last.source, FeedItemSource.repost);
    expect(result.first.track.interaction.isLiked, isTrue);
  });

  test('getDiscoverFeed returns seeded discover items', () async {
    final result = await service.getDiscoverFeed();

    expect(result, hasLength(3));
    expect(result.first.source, FeedItemSource.becauseYouLiked);
    expect(result[1].source, FeedItemSource.becauseYouFollow);
    expect(result.last.source, FeedItemSource.newRelease);
    expect(result.last.track.artistName, 'Travis Scott');
  });
}
