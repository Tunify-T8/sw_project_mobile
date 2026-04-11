import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/core/network/connectivity_provider.dart';
import 'package:software_project/core/storage/storage_keys.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/history_track.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_repository_provider.dart';

import '../helpers/playback_test_utils.dart';

void main() {
  late PlaybackTestEnvironment environment;
  late FakePlayerRepository repository;

  Map<String, dynamic> cachedTrackJson(HistoryTrack track, {String? status}) {
    return <String, dynamic>{
      'trackId': track.trackId,
      'title': track.title,
      'artist': <String, dynamic>{
        'id': track.artist.id,
        'name': track.artist.name,
        'username': track.artist.username,
        'displayName': track.artist.displayName,
        'avatarUrl': track.artist.avatarUrl,
        'tier': track.artist.tier,
      },
      'playedAt': track.playedAt.toIso8601String(),
      'durationSeconds': track.durationSeconds,
      'status': status ?? track.status.name,
      'coverUrl': track.coverUrl,
      'genre': track.genre,
      'releaseDate': track.releaseDate?.toIso8601String(),
      'likeCount': track.likeCount,
      'commentCount': track.commentCount,
      'repostCount': track.repostCount,
      'playCount': track.playCount,
    };
  }

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [playerRepositoryProvider.overrideWithValue(repository)],
    );
  }

  setUp(() {
    environment = createPlaybackTestEnvironment();
    repository = FakePlayerRepository();
  });

  tearDown(() async {
    await environment.dispose();
  });

  test('build merges backend tracks with newer cached entries', () async {
    final backendTrack = sampleHistoryTrack(
      trackId: 'track-1',
      playedAt: DateTime.utc(2026, 4, 4, 20),
    );
    final newerCached = sampleHistoryTrack(
      trackId: 'track-1',
      title: 'Cached Title',
      playedAt: DateTime.utc(2026, 4, 4, 21),
    );
    final cachedOnly = sampleHistoryTrack(trackId: 'track-2');
    environment.storage.seed(
      StorageKeys.cachedListeningHistory,
      jsonEncode(<Map<String, dynamic>>[
        cachedTrackJson(newerCached),
        cachedTrackJson(cachedOnly),
      ]),
    );
    repository.getListeningHistoryHandler =
        ({int page = 1, int limit = 20}) async {
          expect(page, 1);
          expect(limit, 20);
          return <HistoryTrack>[backendTrack];
        };

    final container = buildContainer();
    addTearDown(container.dispose);

    final state = await container.read(listeningHistoryProvider.future);

    expect(state.tracks.length, 2);
    expect(state.tracks.first.title, 'Cached Title');
    expect(state.tracks.last.trackId, 'track-2');
    expect(
      environment.storage.values[StorageKeys.cachedListeningHistory],
      isNotNull,
    );
  });

  test('falls back to cached tracks when backend load fails', () async {
    final cachedTrack = sampleHistoryTrack(trackId: 'track-cache');
    environment.storage.seed(
      StorageKeys.cachedListeningHistory,
      jsonEncode(<Map<String, dynamic>>[cachedTrackJson(cachedTrack)]),
    );
    repository.getListeningHistoryHandler =
        ({int page = 1, int limit = 20}) async {
          throw StateError('network down');
        };

    final container = buildContainer();
    addTearDown(container.dispose);

    final state = await container.read(listeningHistoryProvider.future);

    expect(state.tracks.single.trackId, 'track-cache');
    expect(state.hasMore, isFalse);
  });

  test(
    'loadMore appends unique results and stops when page is short',
    () async {
      repository.getListeningHistoryHandler =
          ({int page = 1, int limit = 20}) async {
            if (page == 1) {
              return List<HistoryTrack>.generate(
                20,
                (index) => sampleHistoryTrack(trackId: 'track-${index + 1}'),
              );
            }
            return <HistoryTrack>[
              sampleHistoryTrack(trackId: 'track-1'),
              sampleHistoryTrack(trackId: 'track-21'),
            ];
          };

      final container = buildContainer();
      addTearDown(container.dispose);
      await container.read(listeningHistoryProvider.future);

      await container.read(listeningHistoryProvider.notifier).loadMore();

      final state = container.read(listeningHistoryProvider).requireValue;
      expect(state.tracks.length, 21);
      expect(state.tracks.first.trackId, 'track-1');
      expect(state.tracks.last.trackId, 'track-21');
      expect(state.currentPage, 2);
      expect(state.hasMore, isFalse);
    },
  );

  test('trackPlayed is optimistic and deduplicates recent repeats', () async {
    repository.getListeningHistoryHandler =
        ({int page = 1, int limit = 20}) async {
          return <HistoryTrack>[];
        };
    final container = buildContainer();
    addTearDown(container.dispose);
    await container.read(listeningHistoryProvider.future);
    final notifier = container.read(listeningHistoryProvider.notifier);
    final track = sampleHistoryTrack(trackId: 'track-7');

    await notifier.trackPlayed(track, needsBackendSync: true);
    await notifier.trackPlayed(track, needsBackendSync: true);

    final state = container.read(listeningHistoryProvider).requireValue;
    expect(state.tracks.length, 1);
    expect(state.tracks.single.trackId, 'track-7');
    expect(state.wasClearedLocally, isFalse);
  });

  test('clearHistory keeps local clear flag and refresh respects it', () async {
    repository.getListeningHistoryHandler =
        ({int page = 1, int limit = 20}) async {
          return <HistoryTrack>[sampleHistoryTrack()];
        };
    final container = buildContainer();
    addTearDown(container.dispose);
    await container.read(listeningHistoryProvider.future);
    final notifier = container.read(listeningHistoryProvider.notifier);

    await notifier.clearHistory();
    await notifier.refresh();

    final state = container.read(listeningHistoryProvider).requireValue;
    expect(state.tracks, isEmpty);
    expect(state.wasClearedLocally, isTrue);
    expect(
      environment.storage.values[StorageKeys.historyClearedLocally],
      'true',
    );
  });

  test('connectivity change from offline to online triggers refresh', () async {
    await environment.dispose();
    environment = createPlaybackTestEnvironment(
      connectivityResults: const [ConnectivityResult.none],
    );
    var calls = 0;
    repository.getListeningHistoryHandler =
        ({int page = 1, int limit = 20}) async {
          calls++;
          return <HistoryTrack>[sampleHistoryTrack(trackId: 'track-$calls')];
        };

    final container = buildContainer();
    addTearDown(container.dispose);
    await container.read(listeningHistoryProvider.future);
    final connectivitySubscription = container.listen(
      connectivityProvider,
      (_, __) {},
    );
    addTearDown(connectivitySubscription.close);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    environment.connectivity.setResults(const [ConnectivityResult.wifi]);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final state = container.read(listeningHistoryProvider).requireValue;
    expect(calls, greaterThanOrEqualTo(2));
    expect(state.tracks.first.trackId, 'track-2');
  });

  test(
    'corrupted cached payload is deleted and yields empty fallback',
    () async {
      environment.storage.seed(StorageKeys.cachedListeningHistory, 'not-json');
      repository.getListeningHistoryHandler =
          ({int page = 1, int limit = 20}) async {
            throw StateError('still offline');
          };

      final container = buildContainer();
      addTearDown(container.dispose);

      final state = await container.read(listeningHistoryProvider.future);

      expect(state.tracks, isEmpty);
      expect(
        environment.storage.values.containsKey(
          StorageKeys.cachedListeningHistory,
        ),
        isFalse,
      );
    },
  );
}
