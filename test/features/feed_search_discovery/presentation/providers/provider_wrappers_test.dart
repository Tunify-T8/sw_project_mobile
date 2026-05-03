import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/data/repository/discovery_repository_impl.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_view_mode.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/feed_provider.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/feed_view_provider.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/trending_provider.dart';

void main() {
  test('feed provider exposes discovery repository implementation', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repository = container.read(feedRepositoryProvider);

    expect(repository, isA<DiscoveryRepositoryImpl>());
  });

  test('trending provider exposes discovery repository implementation', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repository = container.read(trendingRepositoryProvider);

    expect(repository, isA<DiscoveryRepositoryImpl>());
  });

  test('feed view mode provider starts in discover mode and can switch modes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(feedViewModeProvider), FeedViewMode.discover);

    container
        .read(feedViewModeProvider.notifier)
        .setMode(FeedViewMode.classic);

    expect(container.read(feedViewModeProvider), FeedViewMode.classic);
  });
}
