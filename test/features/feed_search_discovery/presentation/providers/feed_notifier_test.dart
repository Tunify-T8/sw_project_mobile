import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_actor_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_source.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_tab_type.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_interaction_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_preview_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/repositories/feed_repository.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/feed_notifier.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/feed_provider.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/feed_state.dart';

import 'feed_notifier_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FeedRepository>()])
void main() {
  late MockFeedRepository repository;
  late ProviderContainer container;
  late FeedNotifier notifier;

  FeedItemEntity buildItem(
    String suffix, {
    FeedItemSource source = FeedItemSource.post,
  }) {
    return FeedItemEntity(
      source: source,
      timeAgo: '${suffix}h',
      actor: FeedActorEntity(
        id: 'actor-$suffix',
        username: 'user-$suffix',
        avatarUrl: 'https://example.com/avatar-$suffix.png',
      ),
      track: TrackPreviewEntity(
        trackId: 'track-$suffix',
        title: 'Track $suffix',
        artistId: 'artist-$suffix',
        artistName: 'Artist $suffix',
        artistAvatar: 'https://example.com/artist-$suffix.png',
        artistVerified: true,
        isFollowingArtist: suffix != '0',
        coverUrl: 'https://example.com/cover-$suffix.png',
        duration: 180,
        listensCount: 1000 + suffix.length,
        likesCount: 100 + suffix.length,
        repostsCount: 10 + suffix.length,
        commentsCount: 5 + suffix.length,
        createdAt: '2026-04-04',
        interaction: TrackInteractionEntity(
          isLiked: suffix.length.isEven,
          isReposted: suffix.length.isOdd,
        ),
      ),
    );
  }

  setUp(() {
    repository = MockFeedRepository();
    container = ProviderContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(repository),
      ],
    );
    notifier = container.read(feedNotifierProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('initial state', () {
    test('starts with expected defaults', () {
      final state = container.read(feedNotifierProvider);

      expect(state.followingItems, isEmpty);
      expect(state.discoverItems, isEmpty);
      expect(state.isDiscoverLoading, isTrue);
      expect(state.isFollowingLoading, isFalse);
      expect(state.hasLoadedDiscover, isFalse);
      expect(state.hasLoadedFollowing, isFalse);
      expect(state.isPreviewing, isFalse);
      expect(state.discoverError, isNull);
      expect(state.followingError, isNull);
    });
  });

  group('loadFeed', () {
    test('loads discover feed, forwards arguments, and emits loading then success', () async {
      final discoverItems = [
        buildItem('1', source: FeedItemSource.becauseYouLiked),
        buildItem('2', source: FeedItemSource.newRelease),
      ];
      final seedFollowing = buildItem('seed-following');
      final staleDiscover = buildItem('stale-discover');
      final states = <FeedState>[];
      final completer = Completer<List<FeedItemEntity>>();

      notifier.state = FeedState(
        followingItems: [seedFollowing],
        discoverItems: [staleDiscover],
        isDiscoverLoading: false,
        followingError: 'keep following error',
        discoverError: 'old discover error',
      );

      container.listen<FeedState>(
        feedNotifierProvider,
        (_, next) => states.add(next),
        fireImmediately: false,
      );

      when(
        repository.getDiscoverFeed(page: 3, limit: 7),
      ).thenAnswer((_) => completer.future);

      final future = notifier.loadFeed(
        tab: FeedType.discover,
        page: 3,
        limit: 7,
      );

      expect(states, hasLength(1));
      expect(states.first.isDiscoverLoading, isTrue);
      expect(states.first.discoverError, isNull);
      expect(states.first.followingError, 'keep following error');
      expect(states.first.discoverItems, [staleDiscover]);
      expect(states.first.followingItems, [seedFollowing]);

      completer.complete(discoverItems);
      await future;

      final state = container.read(feedNotifierProvider);
      expect(states, hasLength(2));
      expect(states.last, same(state));
      expect(state.discoverItems, discoverItems);
      expect(state.followingItems, [seedFollowing]);
      expect(state.isDiscoverLoading, isFalse);
      expect(state.isFollowingLoading, isFalse);
      expect(state.hasLoadedDiscover, isTrue);
      expect(state.hasLoadedFollowing, isFalse);
      expect(state.discoverError, isNull);
      expect(state.followingError, 'keep following error');
      verify(repository.getDiscoverFeed(page: 3, limit: 7)).called(1);
      verifyNever(repository.getFollowingFeed(page: anyNamed('page'), limit: anyNamed('limit')));
    });

    test('loads following feed with default arguments and updates following state only', () async {
      final followingItems = [
        buildItem('3', source: FeedItemSource.post),
      ];
      final discoverExisting = buildItem('discover-existing');

      notifier.state = FeedState(
        discoverItems: [discoverExisting],
        isDiscoverLoading: false,
        discoverError: 'discover stays',
      );

      when(
        repository.getFollowingFeed(page: 1, limit: 20),
      ).thenAnswer((_) async => followingItems);

      await notifier.loadFeed(tab: FeedType.following);

      final state = container.read(feedNotifierProvider);
      expect(state.followingItems, followingItems);
      expect(state.discoverItems, [discoverExisting]);
      expect(state.isFollowingLoading, isFalse);
      expect(state.isDiscoverLoading, isFalse);
      expect(state.hasLoadedFollowing, isTrue);
      expect(state.hasLoadedDiscover, isFalse);
      expect(state.followingError, isNull);
      expect(state.discoverError, 'discover stays');
      verify(repository.getFollowingFeed(page: 1, limit: 20)).called(1);
      verifyNever(repository.getDiscoverFeed(page: anyNamed('page'), limit: anyNamed('limit')));
    });

    test('treats classic tab as following branch', () async {
      final followingItems = [buildItem('classic')];

      when(
        repository.getFollowingFeed(page: 2, limit: 4),
      ).thenAnswer((_) async => followingItems);

      await notifier.loadFeed(
        tab: FeedType.classic,
        page: 2,
        limit: 4,
      );

      final state = container.read(feedNotifierProvider);
      expect(state.followingItems, followingItems);
      expect(state.hasLoadedFollowing, isTrue);
      expect(state.followingError, isNull);
      verify(repository.getFollowingFeed(page: 2, limit: 4)).called(1);
      verifyNever(repository.getDiscoverFeed(page: anyNamed('page'), limit: anyNamed('limit')));
    });

    test('supports empty discover results', () async {
      final existingDiscover = buildItem('existing');

      notifier.state = FeedState(
        discoverItems: [existingDiscover],
        isDiscoverLoading: false,
      );

      when(
        repository.getDiscoverFeed(page: 1, limit: 20),
      ).thenAnswer((_) async => <FeedItemEntity>[]);

      await notifier.loadFeed(tab: FeedType.discover);

      final state = container.read(feedNotifierProvider);
      expect(state.discoverItems, isEmpty);
      expect(state.isDiscoverLoading, isFalse);
      expect(state.hasLoadedDiscover, isTrue);
      expect(state.discoverError, isNull);
      verify(repository.getDiscoverFeed(page: 1, limit: 20)).called(1);
    });

    test('stores discover error and preserves following state when repository throws', () async {
      final states = <FeedState>[];
      final followingKeep = buildItem('following-keep');
      final discoverKeep = buildItem('discover-keep');

      notifier.state = FeedState(
        followingItems: [followingKeep],
        discoverItems: [discoverKeep],
        isDiscoverLoading: false,
        followingError: 'existing following error',
      );

      container.listen<FeedState>(
        feedNotifierProvider,
        (_, next) => states.add(next),
        fireImmediately: false,
      );

      when(
        repository.getDiscoverFeed(page: 5, limit: 2),
      ).thenThrow(Exception('discover failed'));

      await notifier.loadFeed(
        tab: FeedType.discover,
        page: 5,
        limit: 2,
      );

      final state = container.read(feedNotifierProvider);
      expect(states, hasLength(2));
      expect(states.first.isDiscoverLoading, isTrue);
      expect(states.first.discoverError, isNull);
      expect(state.discoverItems, [discoverKeep]);
      expect(state.followingItems, [followingKeep]);
      expect(state.isDiscoverLoading, isFalse);
      expect(state.hasLoadedDiscover, isTrue);
      expect(state.discoverError, 'Exception: discover failed');
      expect(state.followingError, 'existing following error');
      verify(repository.getDiscoverFeed(page: 5, limit: 2)).called(1);
      verifyNever(repository.getFollowingFeed(page: anyNamed('page'), limit: anyNamed('limit')));
    });

    test('stores following error and preserves discover state when repository throws', () async {
      final discoverKeep = buildItem('discover-keep');
      final followingKeep = buildItem('following-keep');

      notifier.state = FeedState(
        discoverItems: [discoverKeep],
        followingItems: [followingKeep],
        isDiscoverLoading: false,
        discoverError: 'discover error stays',
      );

      when(
        repository.getFollowingFeed(page: 4, limit: 6),
      ).thenThrow(StateError('following failed'));

      await notifier.loadFeed(
        tab: FeedType.following,
        page: 4,
        limit: 6,
      );

      final state = container.read(feedNotifierProvider);
      expect(state.followingItems, [followingKeep]);
      expect(state.discoverItems, [discoverKeep]);
      expect(state.isFollowingLoading, isFalse);
      expect(state.hasLoadedFollowing, isTrue);
      expect(state.followingError, 'Bad state: following failed');
      expect(state.discoverError, 'discover error stays');
      verify(repository.getFollowingFeed(page: 4, limit: 6)).called(1);
      verifyNever(repository.getDiscoverFeed(page: anyNamed('page'), limit: anyNamed('limit')));
    });
  });

  group('refreshFeed', () {
    test('refreshes discover items, clears discover error, and keeps flags unchanged', () async {
      final refreshedItems = [
        buildItem('fresh-1', source: FeedItemSource.becauseYouFollow),
      ];
      final oldDiscover = buildItem('old-discover');
      final oldFollowing = buildItem('old-following');

      notifier.state = FeedState(
        discoverItems: [oldDiscover],
        followingItems: [oldFollowing],
        isDiscoverLoading: false,
        isFollowingLoading: true,
        hasLoadedDiscover: true,
        hasLoadedFollowing: true,
        discoverError: 'old discover error',
        followingError: 'keep following error',
        isPreviewing: true,
      );

      when(
        repository.getDiscoverFeed(page: 8, limit: 9),
      ).thenAnswer((_) async => refreshedItems);

      await notifier.refreshFeed(
        tab: FeedType.discover,
        page: 8,
        limit: 9,
      );

      final state = container.read(feedNotifierProvider);
      expect(state.discoverItems, refreshedItems);
      expect(state.followingItems, [oldFollowing]);
      expect(state.discoverError, isNull);
      expect(state.followingError, 'keep following error');
      expect(state.isDiscoverLoading, isFalse);
      expect(state.isFollowingLoading, isTrue);
      expect(state.hasLoadedDiscover, isTrue);
      expect(state.hasLoadedFollowing, isTrue);
      expect(state.isPreviewing, isTrue);
      verify(repository.getDiscoverFeed(page: 8, limit: 9)).called(1);
      verifyNever(repository.getFollowingFeed(page: anyNamed('page'), limit: anyNamed('limit')));
    });

    test('refreshes following items for classic tab and clears following error', () async {
      final refreshedItems = [
        buildItem('fresh-classic'),
        buildItem('fresh-classic-2', source: FeedItemSource.repost),
      ];
      final discoverStays = buildItem('discover-stays');
      final followingOld = buildItem('following-old');

      notifier.state = FeedState(
        discoverItems: [discoverStays],
        followingItems: [followingOld],
        isDiscoverLoading: false,
        hasLoadedDiscover: true,
        followingError: 'old following error',
        discoverError: 'discover stays',
      );

      when(
        repository.getFollowingFeed(page: 2, limit: 3),
      ).thenAnswer((_) async => refreshedItems);

      await notifier.refreshFeed(
        tab: FeedType.classic,
        page: 2,
        limit: 3,
      );

      final state = container.read(feedNotifierProvider);
      expect(state.followingItems, refreshedItems);
      expect(state.discoverItems, [discoverStays]);
      expect(state.followingError, isNull);
      expect(state.discoverError, 'discover stays');
      verify(repository.getFollowingFeed(page: 2, limit: 3)).called(1);
      verifyNever(repository.getDiscoverFeed(page: anyNamed('page'), limit: anyNamed('limit')));
    });

    test('stores discover refresh error without clearing existing items', () async {
      final originalDiscoverItems = [buildItem('discover-existing')];
      final followingExisting = buildItem('following-existing');

      notifier.state = FeedState(
        discoverItems: originalDiscoverItems,
        followingItems: [followingExisting],
        isDiscoverLoading: false,
        hasLoadedDiscover: true,
        followingError: 'keep following error',
      );

      when(
        repository.getDiscoverFeed(page: 1, limit: 20),
      ).thenThrow(Exception('refresh discover failed'));

      await notifier.refreshFeed(tab: FeedType.discover);

      final state = container.read(feedNotifierProvider);
      expect(state.discoverItems, originalDiscoverItems);
      expect(state.followingItems, [followingExisting]);
      expect(state.discoverError, 'Exception: refresh discover failed');
      expect(state.followingError, 'keep following error');
      expect(state.hasLoadedDiscover, isTrue);
      verify(repository.getDiscoverFeed(page: 1, limit: 20)).called(1);
    });

    test('stores following refresh error without clearing existing items', () async {
      final originalFollowingItems = [buildItem('following-existing')];
      final discoverExisting = buildItem('discover-existing');

      notifier.state = FeedState(
        discoverItems: [discoverExisting],
        followingItems: originalFollowingItems,
        isDiscoverLoading: false,
        hasLoadedFollowing: true,
        discoverError: 'keep discover error',
      );

      when(
        repository.getFollowingFeed(page: 9, limit: 1),
      ).thenThrow(Exception('refresh following failed'));

      await notifier.refreshFeed(
        tab: FeedType.following,
        page: 9,
        limit: 1,
      );

      final state = container.read(feedNotifierProvider);
      expect(state.followingItems, originalFollowingItems);
      expect(state.discoverItems, [discoverExisting]);
      expect(state.followingError, 'Exception: refresh following failed');
      expect(state.discoverError, 'keep discover error');
      expect(state.hasLoadedFollowing, isTrue);
      verify(repository.getFollowingFeed(page: 9, limit: 1)).called(1);
    });
  });

  group('togglePreview', () {
    test('toggles preview flag on and off without affecting feed data', () {
      final followingItem = buildItem('following');
      final discoverItem = buildItem('discover');

      notifier.state = FeedState(
        followingItems: [followingItem],
        discoverItems: [discoverItem],
        isDiscoverLoading: false,
        hasLoadedDiscover: true,
        hasLoadedFollowing: true,
      );

      notifier.togglePreview();
      expect(container.read(feedNotifierProvider).isPreviewing, isTrue);
      expect(
        container.read(feedNotifierProvider).followingItems,
        [followingItem],
      );
      expect(
        container.read(feedNotifierProvider).discoverItems,
        [discoverItem],
      );

      notifier.togglePreview();
      final state = container.read(feedNotifierProvider);
      expect(state.isPreviewing, isFalse);
      expect(state.followingItems, [followingItem]);
      expect(state.discoverItems, [discoverItem]);
    });
  });
}
