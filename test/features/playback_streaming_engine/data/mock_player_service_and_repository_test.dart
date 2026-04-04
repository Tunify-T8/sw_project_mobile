import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playback_streaming_engine/data/repository/mock_player_repository_impl.dart';
import 'package:software_project/features/playback_streaming_engine/data/services/mock_player_service.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_context_request.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_event.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';

void main() {
  late MockPlayerService service;

  setUp(() {
    service = MockPlayerService();
  });

  group('MockPlayerService', () {
    test('returns blocked and preview bundle states from track ids', () async {
      final blocked = await service.getPlaybackBundle('track-blocked');
      final preview = await service.getPlaybackBundle('track-preview');
      final playable = await service.getPlaybackBundle('track-playable');

      expect(blocked['playability']['status'], 'blocked');
      expect(preview['playability']['status'], 'preview');
      expect(playable['playability']['status'], 'playable');
    });

    test('returns request stream payload with hls format', () async {
      final stream = await service.requestStreamUrl('track-1');

      expect(stream['trackId'], 'track-1');
      expect(stream['stream']['format'], 'hls');
    });

    test('reportPlaybackEvent inserts and promotes history entries', () async {
      await service.getPlaybackBundle('track-1');
      await service.reportPlaybackEvent(
        trackId: 'track-1',
        action: 'play',
        positionSeconds: 0,
        title: 'First Title',
        artistName: 'Artist',
        coverUrl: 'cover',
        durationSeconds: 90,
      );
      await service.reportPlaybackEvent(
        trackId: 'track-1',
        action: 'play',
        positionSeconds: 5,
        title: 'First Title',
        artistName: 'Artist',
        coverUrl: 'cover',
        durationSeconds: 90,
      );

      final history = await service.getListeningHistory(page: 1, limit: 20);
      final first = (history['data'] as List<dynamic>).first
          as Map<String, dynamic>;

      expect(first['trackId'], 'track-1');
      expect(first['title'], 'First Title');
      expect(first['engagement']['playCount'], 2);
    });

    test('buildPlaybackQueue includes start track and start index', () async {
      final queue = await service.buildPlaybackQueue(
        contextType: 'playlist',
        contextId: 'playlist-1',
        startTrackId: 'custom-track',
        shuffle: true,
        repeat: 'all',
      );

      expect((queue['queue'] as List<dynamic>).first['trackId'], 'custom-track');
      expect(queue['currentIndex'], 0);
      expect(queue['shuffle'], isTrue);
      expect(queue['repeat'], 'all');
    });

    test('seeds listening history and clears it', () async {
      final seeded = await service.getListeningHistory(page: 1, limit: 3);

      expect((seeded['data'] as List<dynamic>).length, 3);

      await service.clearListeningHistory();
      final refilled = await service.getListeningHistory(page: 1, limit: 20);

      expect((refilled['data'] as List<dynamic>), isNotEmpty);
    });
  });

  group('MockPlayerRepository', () {
    test('maps service responses into domain entities', () async {
      final repository = MockPlayerRepository(service: service);

      final bundle = await repository.getPlaybackBundle('track-preview');
      final stream = await repository.requestStreamUrl('track-1');
      final queue = await repository.buildPlaybackQueue(
        const PlaybackContextRequest(
          contextType: PlaybackContextType.feed,
          contextId: 'feed-1',
          startTrackId: 'track-1',
          repeat: RepeatMode.one,
        ),
      );

      expect(bundle.playability.status, PlaybackStatus.preview);
      expect(stream.trackId, 'track-1');
      expect(queue.repeat, RepeatMode.one);
    });

    test('reports events and returns history list', () async {
      final repository = MockPlayerRepository(service: service);

      await repository.reportPlaybackEvent(
        const PlaybackEvent(
          trackId: 'track-1',
          action: PlaybackAction.play,
          positionSeconds: 0,
        ),
      );
      final history = await repository.getListeningHistory();

      expect(history, isNotEmpty);
      expect(history.first.trackId, isNotEmpty);
    });

    test('clear history delegates and noop methods stay safe', () async {
      final repository = MockPlayerRepository(service: service);

      await repository.clearListeningHistory();
      await repository.reportTrackCompleted('track-1');
      await repository.addOfflinePlay('track-1');
      await repository.markOfflinePlayCompleted('track-1');
    });
  });
}
