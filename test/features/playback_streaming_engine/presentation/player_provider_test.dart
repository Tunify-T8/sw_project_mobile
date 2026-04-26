import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/core/storage/storage_keys.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/global_track_store.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/player_seed_track.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_event.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_backend_mode_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_repository_provider.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';

import '../helpers/playback_test_utils.dart';

void main() {
  late PlaybackTestEnvironment environment;
  late FakePlayerRepository repository;
  late TestListeningHistoryNotifier historyNotifier;

  ProviderContainer buildContainer({
    PlayerBackendMode mode = PlayerBackendMode.real,
  }) {
    return ProviderContainer(
      overrides: [
        playerBackendModeProvider.overrideWith((_) => mode),
        playerRepositoryProvider.overrideWithValue(repository),
        listeningHistoryProvider.overrideWith(() => historyNotifier),
      ],
    );
  }

  setUp(() {
    environment = createPlaybackTestEnvironment();
    repository = FakePlayerRepository();
    historyNotifier = TestListeningHistoryNotifier(
      const ListeningHistoryState(),
    );
  });

  tearDown(() async {
    GlobalTrackStore.instance.clear();
    await environment.dispose();
  });

  test('restores persisted session from storage on build', () async {
    environment.storage.seed(
      StorageKeys.cachedPlayerSession,
      jsonEncode(
        encodePlayerSession(
          bundle: sampleBundle(trackId: 'restore-track'),
          streamUrl: sampleStreamUrl(trackId: 'restore-track'),
          queue: sampleQueue(),
          positionSeconds: 33,
          isMuted: true,
          volume: 0.4,
          streamExpiresAt: DateTime.now().add(const Duration(minutes: 10)),
          mediaDurationSeconds: 180,
        ),
      ),
    );
    final container = buildContainer();
    addTearDown(container.dispose);

    final state = await container.read(playerProvider.future);

    expect(state.bundle!.trackId, 'restore-track');
    expect(state.positionSeconds, 33);
    expect(state.isMuted, isTrue);
    expect(state.volume, 0.4);
    expect(state.queue, isNotNull);
  });

  test('loadTrack in mock mode auto-plays and records history after 2 seconds', () async {
    final container = buildContainer(mode: PlayerBackendMode.mock);
    addTearDown(container.dispose);
    await container.read(playerProvider.future);
    final notifier = container.read(playerProvider.notifier);

    await notifier.loadTrack(
      'track-1',
      autoPlay: true,
      seedTrack: const PlayerSeedTrack(
        trackId: 'track-1',
        title: 'Seed Track',
        artistName: 'Seed Artist',
        durationSeconds: 180,
        directAudioUrl: 'https://example.com/seed.m3u8',
      ),
    );

    expect(container.read(playerProvider).requireValue.isPlaying, isTrue);

    environment.justAudio.mostRecentPlayer!.emitPlaybackEvent(
      position: const Duration(seconds: 2),
      duration: const Duration(seconds: 180),
      playing: true,
      processingState: ProcessingStateMessage.ready,
    );
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(historyNotifier.trackPlayedCalls, 1);
    expect(historyNotifier.lastTrackedHistory!.trackId, 'track-1');
    expect(historyNotifier.lastNeedsBackendSync, isFalse);
  });

  test('local file playback queues offline sync and completion when offline', () async {
    await environment.dispose();
    environment = createPlaybackTestEnvironment(
      connectivityResults: const <ConnectivityResult>[ConnectivityResult.none],
    );
    historyNotifier = TestListeningHistoryNotifier(
      const ListeningHistoryState(),
    );

    final container = buildContainer(mode: PlayerBackendMode.mock);
    addTearDown(container.dispose);
    await container.read(playerProvider.future);
    final notifier = container.read(playerProvider.notifier);

    await notifier.loadTrack(
      'offline-track',
      autoPlay: true,
      seedTrack: const PlayerSeedTrack(
        trackId: 'offline-track',
        title: 'Offline Track',
        artistName: 'Seed Artist',
        durationSeconds: 180,
        localFilePath: 'C:/music/offline.mp3',
      ),
    );

    environment.justAudio.mostRecentPlayer!.emitPlaybackEvent(
      position: const Duration(seconds: 2),
      duration: const Duration(seconds: 180),
      playing: true,
      processingState: ProcessingStateMessage.ready,
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    environment.justAudio.mostRecentPlayer!.emitPlaybackEvent(
      position: const Duration(seconds: 170),
      duration: const Duration(seconds: 180),
      playing: true,
      processingState: ProcessingStateMessage.ready,
    );
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(historyNotifier.lastNeedsBackendSync, isTrue);
    expect(repository.addedOfflinePlays, contains('offline-track'));
    expect(repository.completedOfflinePlays, contains('offline-track'));
  });

  test('playback controls update state and report events', () async {
    final container = buildContainer(mode: PlayerBackendMode.mock);
    addTearDown(container.dispose);
    await container.read(playerProvider.future);
    final notifier = container.read(playerProvider.notifier);

    await notifier.loadTrack(
      'track-2',
      autoPlay: false,
      seedTrack: const PlayerSeedTrack(
        trackId: 'track-2',
        title: 'Track Two',
        artistName: 'Artist',
        durationSeconds: 120,
        directAudioUrl: 'https://example.com/two.m3u8',
      ),
    );
    await notifier.play();
    environment.justAudio.mostRecentPlayer!.emitPlaybackEvent(
      duration: const Duration(seconds: 140),
      playing: true,
      processingState: ProcessingStateMessage.ready,
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await notifier.seek(45);
    await notifier.pause();
    notifier.toggleMute();
    notifier.setVolume(0.5);

    final state = container.read(playerProvider).requireValue;
    expect(state.isPlaying, isFalse);
    expect(state.positionSeconds, 45);
    expect(state.isMuted, isTrue);
    expect(state.volume, 0.5);
    expect(state.mediaDurationSeconds, isNotNull);
    expect(repository.reportedEvents.map((event) => event.action), containsAll([
      PlaybackAction.play,
      PlaybackAction.progress,
      PlaybackAction.pause,
    ]));
  });

  test('queue helpers build, next, previous, and jump using stored seed tracks', () async {
    GlobalTrackStore.instance
      ..add(
        sampleUploadItem(
          id: 'track-1',
          audioUrl: 'https://example.com/one.m3u8',
        ),
      )
      ..add(
        sampleUploadItem(
          id: 'track-2',
          title: 'Track Two',
          audioUrl: 'https://example.com/two.m3u8',
        ),
      )
      ..add(
        sampleUploadItem(
          id: 'track-3',
          title: 'Track Three',
          audioUrl: 'https://example.com/three.m3u8',
        ),
      );
    repository.buildPlaybackQueueHandler = (request) async {
      return sampleQueue(
        trackIds: const <String>['track-1', 'track-2', 'track-3'],
        currentIndex: 0,
        repeat: request.repeat,
        shuffle: request.shuffle,
      );
    };
    final container = buildContainer(mode: PlayerBackendMode.mock);
    addTearDown(container.dispose);
    await container.read(playerProvider.future);
    final notifier = container.read(playerProvider.notifier);

    await notifier.buildAndLoadQueue(
      contextType: PlaybackContextType.feed,
      contextId: 'feed-1',
      startTrackId: 'track-1',
      repeat: RepeatMode.all,
      autoPlay: false,
    );
    expect(container.read(playerProvider).requireValue.bundle!.trackId, 'track-1');

    await notifier.next();
    expect(container.read(playerProvider).requireValue.bundle!.trackId, 'track-2');

    await notifier.previous();
    expect(container.read(playerProvider).requireValue.bundle!.trackId, 'track-1');

    await notifier.jumpToQueueIndex(2);
    final state = container.read(playerProvider).requireValue;
    expect(state.bundle!.trackId, 'track-3');
    expect(state.queue!.currentIndex, 2);
  });

  test('reorderQueue persists visible circular next-up order', () async {
    final container = buildContainer(mode: PlayerBackendMode.mock);
    addTearDown(container.dispose);
    await container.read(playerProvider.future);
    final notifier = container.read(playerProvider.notifier);

    await notifier.loadTrack(
      'track-3',
      autoPlay: false,
      seedTrack: const PlayerSeedTrack(
        trackId: 'track-3',
        title: 'Track Three',
        artistName: 'Artist',
        durationSeconds: 120,
      ),
      queue: sampleQueue(
        trackIds: const <String>['track-1', 'track-2', 'track-3', 'track-4'],
        currentIndex: 2,
      ),
    );

    notifier.reorderQueue(1, 0);

    final queue = container.read(playerProvider).requireValue.queue!;
    expect(queue.currentIndex, 2);
    expect(queue.trackIds[queue.currentIndex], 'track-3');
    expect(
      queue.trackIds,
      const <String>['track-4', 'track-2', 'track-3', 'track-1'],
    );
  });

  test('preview tracks stop automatically at preview end', () async {
    repository.getPlaybackBundleHandler = (trackId, {String? privateToken}) async {
      return sampleBundle(
        trackId: trackId,
        status: PlaybackStatus.preview,
        previewEnabled: true,
        previewStartSeconds: 5,
        previewDurationSeconds: 30,
        durationSeconds: 180,
      );
    };
    repository.requestStreamUrlHandler = (
      trackId, {
      String quality = 'auto',
      String? privateToken,
    }) async {
      return sampleStreamUrl(trackId: trackId);
    };
    final container = buildContainer();
    addTearDown(container.dispose);
    await container.read(playerProvider.future);
    final notifier = container.read(playerProvider.notifier);

    await notifier.loadTrack('preview-track');
    await notifier.play();
    environment.justAudio.mostRecentPlayer!.emitPlaybackEvent(
      position: const Duration(seconds: 35),
      duration: const Duration(seconds: 180),
      playing: true,
      processingState: ProcessingStateMessage.ready,
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final state = container.read(playerProvider).requireValue;
    expect(state.isPlaying, isFalse);
    expect(state.positionSeconds, 35);
  });

  test('lifecycle changes persist session and report current progress', () async {
    final container = buildContainer(mode: PlayerBackendMode.mock);
    addTearDown(container.dispose);
    await container.read(playerProvider.future);
    final notifier = container.read(playerProvider.notifier);

    await notifier.loadTrack(
      'track-life',
      autoPlay: true,
      seedTrack: const PlayerSeedTrack(
        trackId: 'track-life',
        title: 'Lifecycle',
        artistName: 'Artist',
        durationSeconds: 100,
        directAudioUrl: 'https://example.com/life.m3u8',
      ),
    );

    notifier.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(
      environment.storage.values[StorageKeys.cachedPlayerSession],
      isNotNull,
    );
    expect(repository.reportedEvents, isNotEmpty);
  });

  test('real mode falls back to seed bundle when repository bundle request fails', () async {
    repository.getPlaybackBundleHandler = (trackId, {String? privateToken}) async {
      throw StateError('bundle failed');
    };
    repository.requestStreamUrlHandler = (
      trackId, {
      String quality = 'auto',
      String? privateToken,
    }) async {
      return sampleStreamUrl(trackId: trackId);
    };
    final container = buildContainer();
    addTearDown(container.dispose);
    await container.read(playerProvider.future);

    await container.read(playerProvider.notifier).loadTrack(
      'fallback-track',
      seedTrack: const PlayerSeedTrack(
        trackId: 'fallback-track',
        title: 'Seed Fallback',
        artistName: 'Seed Artist',
        durationSeconds: 77,
      ),
    );

    final state = container.read(playerProvider).requireValue;
    expect(state.bundle!.title, 'Seed Fallback');
    expect(state.bundle!.artist.name, 'Seed Artist');
  });

  test('loadTrack forwards private token to bundle and stream requests', () async {
    final seenBundleTokens = <String?>[];
    final seenStreamTokens = <String?>[];

    repository.getPlaybackBundleHandler = (trackId, {String? privateToken}) async {
      seenBundleTokens.add(privateToken);
      return sampleBundle(trackId: trackId);
    };
    repository.requestStreamUrlHandler = (
      trackId, {
      String quality = 'auto',
      String? privateToken,
    }) async {
      seenStreamTokens.add(privateToken);
      return sampleStreamUrl(trackId: trackId);
    };

    final container = buildContainer();
    addTearDown(container.dispose);
    await container.read(playerProvider.future);

    await container.read(playerProvider.notifier).loadTrack(
      'private-track',
      privateToken: 'abc123',
    );

    final state = container.read(playerProvider).requireValue;
    expect(state.privateToken, 'abc123');
    expect(seenBundleTokens, ['abc123']);
    expect(seenStreamTokens, ['abc123']);
  });
}
