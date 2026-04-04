import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/trending_genre_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/trending_track_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/repositories/trending_repository.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/trending_notifier.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/trending_provider.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/trending_state.dart';

import 'trending_notifier_test.mocks.dart';

@GenerateNiceMocks([MockSpec<TrendingRepository>()])
void main() {
  late MockTrendingRepository repository;
  late ProviderContainer container;
  late TrendingNotifier notifier;

  final popTrending = TrendingGenreEntity(
    genre: 'Pop',
    tracks: [
      TrendingTrackEntity(
        trackId: 'pop-1',
        title: 'Midnight Echo',
        artistName: 'Luna Waves',
        coverUrl: 'https://example.com/pop-1.jpg',
        isLiked: true,
        isReposted: false,
      ),
    ],
  );

  setUp(() {
    repository = MockTrendingRepository();
    container = ProviderContainer(
      overrides: [
        trendingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    notifier = container.read(trendingNotifierProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('initial state', () {
    test('starts empty and not loading', () {
      final state = container.read(trendingNotifierProvider);

      expect(state.trending, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });
  });

  group('loadTrending', () {
    test('emits loading then success and forwards genre', () async {
      final states = <TrendingState>[];
      final completer = Completer<TrendingGenreEntity>();

      notifier.state = TrendingState(trending: popTrending, error: 'old error');

      container.listen<TrendingState>(
        trendingNotifierProvider,
        (_, next) => states.add(next),
        fireImmediately: false,
      );

      when(
        repository.getTrending(genre: 'pop'),
      ).thenAnswer((_) => completer.future);

      final future = notifier.loadTrending(genre: 'pop');

      expect(states, hasLength(1));
      expect(states.first.isLoading, isTrue);
      expect(states.first.error, isNull);
      expect(states.first.trending, popTrending);

      completer.complete(popTrending);
      await future;

      final state = container.read(trendingNotifierProvider);
      expect(states, hasLength(2));
      expect(state.trending, popTrending);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      verify(repository.getTrending(genre: 'pop')).called(1);
    });

    test('stores error and keeps previous trending data on failure', () async {
      notifier.state = TrendingState(trending: popTrending);
      when(
        repository.getTrending(genre: 'jazz'),
      ).thenThrow(Exception('trending failed'));

      await notifier.loadTrending(genre: 'jazz');

      final state = container.read(trendingNotifierProvider);
      expect(state.trending, popTrending);
      expect(state.isLoading, isFalse);
      expect(state.error, 'Exception: trending failed');
      verify(repository.getTrending(genre: 'jazz')).called(1);
    });
  });
}
