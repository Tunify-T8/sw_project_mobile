import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/core/storage/storage_keys.dart';
import 'package:software_project/features/playback_streaming_engine/data/repository/real_player_repository_impl.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_context_request.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_event.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';

import '../helpers/playback_test_utils.dart';

void main() {
  late PlaybackTestEnvironment environment;
  late FakeStreamingApi api;
  late RealPlayerRepository repository;

  DioException retryableError([DioExceptionType type = DioExceptionType.connectionError]) {
    return DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: type,
    );
  }

  DioException badResponseError(int statusCode) {
    return DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: statusCode,
      ),
      type: DioExceptionType.badResponse,
    );
  }

  setUp(() {
    environment = createPlaybackTestEnvironment();
    api = FakeStreamingApi();
    repository = RealPlayerRepository(api);
  });

  tearDown(() async {
    await environment.dispose();
  });

  test('maps direct repository operations through the api', () async {
    var clearCalled = false;
    String? completedTrackId;
    api.clearListeningHistoryHandler = () async {
      clearCalled = true;
    };
    api.reportTrackCompletedHandler = (trackId) async {
      completedTrackId = trackId;
    };

    final bundle = await repository.getPlaybackBundle('track-1');
    final stream = await repository.requestStreamUrl('track-1', quality: '320');
    final queue = await repository.buildPlaybackQueue(
      const PlaybackContextRequest(
        contextType: PlaybackContextType.profile,
        contextId: 'profile-1',
        startTrackId: 'track-1',
        repeat: RepeatMode.all,
      ),
    );
    final history = await repository.getListeningHistory(page: 1, limit: 10);
    await repository.clearListeningHistory();
    await repository.reportTrackCompleted('track-1');

    expect(bundle.trackId, 'track-1');
    expect(stream.trackId, 'track-1');
    expect(queue.repeat, RepeatMode.all);
    expect(history.single.trackId, 'track-1');
    expect(clearCalled, isTrue);
    expect(completedTrackId, 'track-1');
  });

  test('queues retryable playback events and flushes them later', () async {
    final sent = <PlaybackEvent>[];
    var fail = true;
    api.reportPlaybackEventHandler = ({
      required String trackId,
      required PlaybackAction action,
      required int positionSeconds,
    }) async {
      if (fail) throw retryableError();
      sent.add(
        PlaybackEvent(
          trackId: trackId,
          action: action,
          positionSeconds: positionSeconds,
        ),
      );
    };

    await repository.reportPlaybackEvent(
      const PlaybackEvent(
        trackId: 'track-1',
        action: PlaybackAction.play,
        positionSeconds: 0,
      ),
    );

    expect(
      environment.storage.values[StorageKeys.pendingPlaybackEvents],
      isNotNull,
    );

    fail = false;
    await repository.reportPlaybackEvent(
      const PlaybackEvent(
        trackId: 'track-1',
        action: PlaybackAction.progress,
        positionSeconds: 12,
      ),
    );

    expect(sent.map((event) => event.action), [
      PlaybackAction.play,
      PlaybackAction.progress,
    ]);
    expect(
      environment.storage.values.containsKey(StorageKeys.pendingPlaybackEvents),
      isFalse,
    );
  });

  test('deduplicates queued play events and replaces older progress events', () async {
    api.reportPlaybackEventHandler = ({
      required String trackId,
      required PlaybackAction action,
      required int positionSeconds,
    }) async {
      throw retryableError();
    };

    await repository.reportPlaybackEvent(
      const PlaybackEvent(
        trackId: 'track-1',
        action: PlaybackAction.play,
        positionSeconds: 0,
      ),
    );
    await repository.reportPlaybackEvent(
      const PlaybackEvent(
        trackId: 'track-1',
        action: PlaybackAction.play,
        positionSeconds: 0,
      ),
    );
    await repository.reportPlaybackEvent(
      const PlaybackEvent(
        trackId: 'track-1',
        action: PlaybackAction.progress,
        positionSeconds: 7,
      ),
    );
    await repository.reportPlaybackEvent(
      const PlaybackEvent(
        trackId: 'track-1',
        action: PlaybackAction.pause,
        positionSeconds: 9,
      ),
    );

    final raw = environment.storage.values[StorageKeys.pendingPlaybackEvents]!;
    final decoded = jsonDecode(raw) as List<dynamic>;

    expect(decoded.length, 2);
    expect(decoded[0]['action'], 'play');
    expect(decoded[1]['action'], 'pause');
    expect(decoded[1]['positionSeconds'], 9);
  });

  test('rethrows non retryable playback errors', () async {
    api.reportPlaybackEventHandler = ({
      required String trackId,
      required PlaybackAction action,
      required int positionSeconds,
    }) async {
      throw badResponseError(400);
    };

    expect(
      () => repository.reportPlaybackEvent(
        const PlaybackEvent(
          trackId: 'track-1',
          action: PlaybackAction.pause,
          positionSeconds: 5,
        ),
      ),
      throwsA(isA<DioException>()),
    );
  });

  test('invalid pending event cache is discarded before use', () async {
    environment.storage.seed(StorageKeys.pendingPlaybackEvents, 'not json');
    api.reportPlaybackEventHandler = ({
      required String trackId,
      required PlaybackAction action,
      required int positionSeconds,
    }) async {};

    await repository.reportPlaybackEvent(
      const PlaybackEvent(
        trackId: 'track-2',
        action: PlaybackAction.play,
        positionSeconds: 1,
      ),
    );

    expect(
      environment.storage.values.containsKey(StorageKeys.pendingPlaybackEvents),
      isFalse,
    );
  });

  test('stores offline plays with dedupe and completion state', () async {
    await repository.addOfflinePlay('track-1');
    await repository.addOfflinePlay('track-1');
    await repository.markOfflinePlayCompleted('track-1');

    final raw = environment.storage.values[StorageKeys.pendingOfflinePlays]!;
    final decoded = jsonDecode(raw) as List<dynamic>;

    expect(decoded.length, 1);
    expect(decoded.single['trackId'], 'track-1');
    expect(decoded.single['completed'], isTrue);
  });

  test('flushes offline plays before loading listening history', () async {
    environment.storage.seed(
      StorageKeys.pendingOfflinePlays,
      jsonEncode(
      <Map<String, dynamic>>[
        {
          'trackId': 'track-1',
          'playedAt': DateTime.utc(2026, 4, 4, 20).toIso8601String(),
          'completed': false,
        },
      ],
    ),
    );
    List<String> flushedIds = <String>[];
    api.reportBatchOfflinePlaysHandler = (plays) async {
      flushedIds = plays.map((play) => play.trackId).toList(growable: false);
    };

    final history = await repository.getListeningHistory();

    expect(flushedIds, ['track-1']);
    expect(history.single.trackId, 'track-1');
    expect(
      environment.storage.values.containsKey(StorageKeys.pendingOfflinePlays),
      isFalse,
    );
  });

  test('keeps offline plays on retryable batch errors and clears on bad request', () async {
    environment.storage.seed(
      StorageKeys.pendingOfflinePlays,
      jsonEncode(
      <Map<String, dynamic>>[
        {
          'trackId': 'track-1',
          'playedAt': DateTime.utc(2026, 4, 4, 20).toIso8601String(),
          'completed': false,
        },
      ],
    ),
    );
    api.reportBatchOfflinePlaysHandler = (_) async => throw retryableError();

    await repository.getListeningHistory();

    expect(
      environment.storage.values.containsKey(StorageKeys.pendingOfflinePlays),
      isTrue,
    );

    api.reportBatchOfflinePlaysHandler = (_) async => throw badResponseError(400);
    await repository.getListeningHistory();

    expect(
      environment.storage.values.containsKey(StorageKeys.pendingOfflinePlays),
      isFalse,
    );
  });

  test('invalid offline play cache is removed before adding a new record', () async {
    environment.storage.seed(StorageKeys.pendingOfflinePlays, 'bad json');

    await repository.addOfflinePlay('track-9');

    final raw = environment.storage.values[StorageKeys.pendingOfflinePlays]!;
    final decoded = jsonDecode(raw) as List<dynamic>;
    expect(decoded.single['trackId'], 'track-9');
  });
}
