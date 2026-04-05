import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/history_track_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/playability_status_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/playback_context_response_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/preview_info_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/stream_response_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/track_artist_summary_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/track_engagement_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/track_playback_bundle_dto.dart';

import '../helpers/playback_test_utils.dart';

void main() {
  group('HistoryTrackDto', () {
    test('parses full payload with nested artist and engagement', () {
      final dto = HistoryTrackDto.fromJson(sampleHistoryJson());

      expect(dto.trackId, 'track-1');
      expect(dto.artist.name, 'DJ Test');
      expect(dto.likeCount, 8);
      expect(dto.playCount, 50);
      expect(dto.status, 'playable');
    });

    test('falls back to string artist and playability status', () {
      final dto = HistoryTrackDto.fromJson(<String, dynamic>{
        'trackId': 'track-2',
        'title': 'Fallback',
        'artist': 'Plain Artist',
        'playedAt': DateTime.utc(2026, 4, 4).toIso8601String(),
        'durationSeconds': 90,
        'playability': <String, dynamic>{'status': 'preview'},
      });

      expect(dto.artist.name, 'Plain Artist');
      expect(dto.artist.tier, 'free');
      expect(dto.status, 'preview');
    });
  });

  test('PlayabilityStatusDto parses defaults', () {
    final dto = PlayabilityStatusDto.fromJson(const <String, dynamic>{});

    expect(dto.status, 'blocked');
    expect(dto.regionBlocked, isFalse);
    expect(dto.requiresSubscription, isFalse);
  });

  group('PlaybackContextResponseDto', () {
    test('parses mixed queue item shapes', () {
      final dto = PlaybackContextResponseDto.fromJson(
        sampleQueueJson(
          queue: <dynamic>[
            'track-1',
            <String, dynamic>{'trackId': 'track-2'},
            99,
          ],
          currentIndex: 1,
          shuffle: true,
          repeat: 'all',
        ),
      );

      expect(dto.trackIds, ['track-1', 'track-2', '99']);
      expect(dto.currentIndex, 1);
      expect(dto.shuffle, isTrue);
      expect(dto.repeat, 'all');
    });
  });

  test('PreviewInfoDto uses preview defaults', () {
    final dto = PreviewInfoDto.fromJson(const <String, dynamic>{});

    expect(dto.enabled, isFalse);
    expect(dto.previewDurationSeconds, 30);
    expect(dto.previewStartSeconds, 0);
  });

  group('StreamResponseDto', () {
    test('parses nested stream shape', () {
      final dto = StreamResponseDto.fromJson(
        sampleStreamResponseJson(trackId: 'track-8'),
        'fallback-id',
      );

      expect(dto.trackId, 'track-8');
      expect(dto.url, contains('stream.m3u8'));
      expect(dto.format, 'hls');
    });

    test('falls back to root object values', () {
      final dto = StreamResponseDto.fromJson(const <String, dynamic>{
        'url': 'https://example.com/file.mp3',
        'expiresInSeconds': 300,
        'format': 'mp3',
      }, 'fallback-id');

      expect(dto.trackId, 'fallback-id');
      expect(dto.url, contains('file.mp3'));
      expect(dto.expiresInSeconds, 300);
    });
  });

  group('TrackArtistSummaryDto', () {
    test('prefers displayName, then name, then username, then default', () {
      expect(
        TrackArtistSummaryDto.fromJson(const <String, dynamic>{
          'displayName': 'Display',
          'name': 'Name',
          'username': 'username',
        }).name,
        'Display',
      );
      expect(
        TrackArtistSummaryDto.fromJson(const <String, dynamic>{
          'name': 'Name',
          'username': 'username',
        }).name,
        'Name',
      );
      expect(
        TrackArtistSummaryDto.fromJson(const <String, dynamic>{
          'username': 'username',
        }).name,
        'username',
      );
      expect(
        TrackArtistSummaryDto.fromJson(const <String, dynamic>{}).name,
        'Unknown artist',
      );
    });
  });

  test('TrackEngagementDto parses defaults', () {
    final dto = TrackEngagementDto.fromJson(const <String, dynamic>{});

    expect(dto.likeCount, 0);
    expect(dto.isSaved, isFalse);
  });

  group('TrackPlaybackBundleDto', () {
    test('parses nested data wrapper', () {
      final dto = TrackPlaybackBundleDto.fromJson(<String, dynamic>{
        'data': sampleBundleJson(
          trackId: 'track-3',
          previewEnabled: true,
          scheduledReleaseDate: DateTime.utc(2026, 5, 1).toIso8601String(),
        ),
      });

      expect(dto.trackId, 'track-3');
      expect(dto.artist.name, 'DJ Test');
      expect(dto.preview.enabled, isTrue);
      expect(dto.scheduledReleaseDate, contains('2026-05-01'));
    });

    test('fills safe defaults for missing nested objects', () {
      final dto = TrackPlaybackBundleDto.fromJson(const <String, dynamic>{
        'trackId': 'track-4',
        'title': 'Sparse',
        'durationSeconds': 1,
      });

      expect(dto.artist.name, 'Unknown artist');
      expect(dto.engagement.likeCount, 0);
      expect(dto.playability.status, 'playable');
      expect(dto.preview.previewDurationSeconds, 30);
    });
  });
}
