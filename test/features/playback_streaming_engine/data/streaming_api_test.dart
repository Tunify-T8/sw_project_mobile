import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/network/api_endpoints.dart';
import 'package:software_project/features/playback_streaming_engine/data/api/streaming_api.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/offline_play_record.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_event.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';

import '../helpers/playback_test_utils.dart';
import '../../audio_upload_and_management/helpers/local_upload_test_mocks.dart';

void main() {
  late MockDio mockDio;
  late StreamingApi api;

  Response<dynamic> response(dynamic data) => Response<dynamic>(
    data: data,
    requestOptions: RequestOptions(path: '/test'),
    statusCode: 200,
  );

  DioException dioError(int statusCode) => DioException(
    requestOptions: RequestOptions(path: '/test'),
    response: Response<dynamic>(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: statusCode,
    ),
    type: DioExceptionType.badResponse,
  );

  setUp(() {
    mockDio = MockDio();
    api = StreamingApi(mockDio);
  });

  group('getPlaybackBundle', () {
    test('calls playback endpoint and unwraps data payload', () async {
      when(
        mockDio.get(
          ApiEndpoints.trackPlayback('track-1'),
          queryParameters: <String, String>{'privateToken': 'secret'},
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer(
        (_) async => response(<String, dynamic>{
          'data': sampleBundleJson(trackId: 'track-1'),
        }),
      );

      final result = await api.getPlaybackBundle(
        'track-1',
        privateToken: 'secret',
      );

      expect(result.trackId, 'track-1');
      verify(
        mockDio.get(
          ApiEndpoints.trackPlayback('track-1'),
          queryParameters: <String, String>{'privateToken': 'secret'},
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).called(1);
    });

    test('throws StateError for invalid response shape', () async {
      when(
        mockDio.get(
          ApiEndpoints.trackPlayback('track-1'),
          queryParameters: anyNamed('queryParameters'),
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((_) async => response(<dynamic>[]));

      expect(
        () => api.getPlaybackBundle('track-1'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('requestStreamUrl', () {
    test('uses GET when current backend succeeds', () async {
      when(
        mockDio.get(
          ApiEndpoints.trackStream('track-1'),
          queryParameters: anyNamed('queryParameters'),
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((_) async => response(sampleStreamResponseJson()));

      final result = await api.requestStreamUrl('track-1');

      expect(result.trackId, 'track-1');
      expect(result.format, 'hls');
      verifyNever(
        mockDio.post(
          ApiEndpoints.trackStream('track-1'),
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onSendProgress: anyNamed('onSendProgress'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      );
    });

    test('falls back to POST for 404 and forwards quality', () async {
      when(
        mockDio.get(
          ApiEndpoints.trackStream('track-1'),
          queryParameters: anyNamed('queryParameters'),
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(dioError(404));
      when(
        mockDio.post(
          ApiEndpoints.trackStream('track-1'),
          data: const <String, dynamic>{'quality': '320'},
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onSendProgress: anyNamed('onSendProgress'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((_) async => response(sampleStreamResponseJson()));

      final result = await api.requestStreamUrl('track-1', quality: '320');

      expect(result.url, contains('stream.m3u8'));
      verify(
        mockDio.post(
          ApiEndpoints.trackStream('track-1'),
          data: const <String, dynamic>{'quality': '320'},
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onSendProgress: anyNamed('onSendProgress'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).called(1);
    });

    test('rethrows non fallback dio errors', () async {
      when(
        mockDio.get(
          ApiEndpoints.trackStream('track-1'),
          queryParameters: anyNamed('queryParameters'),
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(dioError(500));

      expect(
        () => api.requestStreamUrl('track-1'),
        throwsA(isA<DioException>()),
      );
    });
  });

  test('reportPlaybackEvent is intentionally a no-op', () async {
    await api.reportPlaybackEvent(
      trackId: 'track-1',
      action: PlaybackAction.play,
      positionSeconds: 1,
    );

    verifyZeroInteractions(mockDio);
  });

  group('buildPlaybackQueue', () {
    test('posts modern queue request body', () async {
      when(
        mockDio.post(
          ApiEndpoints.playbackContext,
          data: const <String, dynamic>{
            'contextType': 'playlist',
            'contextId': 'playlist-1',
            'startTrackId': 'track-9',
            'shuffle': true,
            'repeat': 'all',
          },
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onSendProgress: anyNamed('onSendProgress'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer(
        (_) async =>
            response(<String, dynamic>{'data': sampleQueueJson(repeat: 'all')}),
      );

      final queue = await api.buildPlaybackQueue(
        contextType: 'playlist',
        contextId: 'playlist-1',
        startTrackId: 'track-9',
        shuffle: true,
        repeat: 'all',
      );

      expect(queue.repeat, 'all');
      expect(queue.trackIds, ['track-1', 'track-2']);
    });

    test('falls back to legacy endpoint on 405', () async {
      when(
        mockDio.post(
          ApiEndpoints.playbackContext,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onSendProgress: anyNamed('onSendProgress'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(dioError(405));
      when(
        mockDio.post(
          ApiEndpoints.legacyPlaybackContext,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onSendProgress: anyNamed('onSendProgress'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((_) async => response(sampleQueueJson(repeat: 'one')));

      final queue = await api.buildPlaybackQueue(
        contextType: 'feed',
        contextId: 'feed-1',
      );

      expect(queue.repeat, 'one');
      verify(
        mockDio.post(
          ApiEndpoints.legacyPlaybackContext,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onSendProgress: anyNamed('onSendProgress'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).called(1);
    });
  });

  group('getListeningHistory', () {
    test('parses primary response list', () async {
      when(
        mockDio.get(
          ApiEndpoints.listeningHistory,
          queryParameters: const <String, dynamic>{'page': 2, 'limit': 5},
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer(
        (_) async => response(<String, dynamic>{
          'data': <Map<String, dynamic>>[sampleHistoryJson()],
        }),
      );

      final items = await api.getListeningHistory(page: 2, limit: 5);

      expect(items.single.trackId, 'track-1');
    });

    test('falls back to legacy endpoint on 404', () async {
      when(
        mockDio.get(
          ApiEndpoints.listeningHistory,
          queryParameters: anyNamed('queryParameters'),
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(dioError(404));
      when(
        mockDio.get(
          ApiEndpoints.legacyListeningHistory,
          queryParameters: anyNamed('queryParameters'),
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer(
        (_) async => response(<String, dynamic>{
          'data': <Map<String, dynamic>>[sampleHistoryJson(trackId: 'legacy')],
        }),
      );

      final items = await api.getListeningHistory();

      expect(items.single.trackId, 'legacy');
    });

    test('throws StateError when response is not a map', () async {
      when(
        mockDio.get(
          ApiEndpoints.listeningHistory,
          queryParameters: anyNamed('queryParameters'),
          data: anyNamed('data'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((_) async => response(<dynamic>[]));

      expect(() => api.getListeningHistory(), throwsA(isA<StateError>()));
    });
  });

  test('clearListeningHistory is intentionally a no-op', () async {
    await api.clearListeningHistory();
    verifyZeroInteractions(mockDio);
  });

  group('reportTrackCompleted', () {
    test('ignores 409 responses', () async {
      when(
        mockDio.post(
          ApiEndpoints.trackPlayed('track-1'),
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onSendProgress: anyNamed('onSendProgress'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(dioError(409));

      await api.reportTrackCompleted('track-1');
    });

    test('rethrows other dio errors', () async {
      when(
        mockDio.post(
          ApiEndpoints.trackPlayed('track-1'),
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onSendProgress: anyNamed('onSendProgress'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenThrow(dioError(500));

      expect(
        () => api.reportTrackCompleted('track-1'),
        throwsA(isA<DioException>()),
      );
    });
  });

  test('reportBatchOfflinePlays posts serialized play list', () async {
    when(
      mockDio.post(
        ApiEndpoints.batchPlays,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      ),
    ).thenAnswer((_) async => response(const <String, dynamic>{'ok': true}));

    await api.reportBatchOfflinePlays(<OfflinePlayRecord>[
      OfflinePlayRecord(
        trackId: 'track-1',
        playedAt: DateTime.utc(2026, 4, 4, 20),
      ),
    ]);

    verify(
      mockDio.post(
        ApiEndpoints.batchPlays,
        data: argThat(
          containsPair('plays', isA<List<dynamic>>()),
          named: 'data',
        ),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      ),
    ).called(1);
  });

  test('contextTypeToString maps every playback context', () {
    expect(
      StreamingApi.contextTypeToString(PlaybackContextType.track),
      'track',
    );
    expect(StreamingApi.contextTypeToString(PlaybackContextType.feed), 'feed');
    expect(
      StreamingApi.contextTypeToString(PlaybackContextType.playlist),
      'playlist',
    );
    expect(
      StreamingApi.contextTypeToString(PlaybackContextType.profile),
      'profile',
    );
    expect(
      StreamingApi.contextTypeToString(PlaybackContextType.history),
      'history',
    );
  });
}
