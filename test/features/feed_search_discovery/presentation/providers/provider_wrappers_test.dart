import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/data/repository/mock_feed_repository_impl.dart';
import 'package:software_project/features/feed_search_discovery/data/repository/mock_trending_repository_impl.dart';
import 'package:software_project/features/feed_search_discovery/data/services/mock_feed_service.dart';
import 'package:software_project/features/feed_search_discovery/data/services/mock_trending_service.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/feed_provider.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/trending_provider.dart';

void main() {
  test('feed providers expose mock service and repository instances', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final service = container.read(feedServiceProvider);
    final repository = container.read(feedRepositoryProvider);

    expect(service, isA<MockFeedService>());
    expect(repository, isA<MockFeedRepositoryImpl>());
  });

  test('trending providers expose mock service and repository instances', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final service = container.read(trendingServiceProvider);
    final repository = container.read(trendingRepositoryProvider);

    expect(service, isA<MockTrendingService>());
    expect(repository, isA<MockTrendingRepositoryImpl>());
  });
}
