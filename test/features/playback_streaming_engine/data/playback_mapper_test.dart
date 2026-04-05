import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/history_track_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/playability_status_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/playback_context_response_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/preview_info_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/stream_response_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/track_artist_summary_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/track_engagement_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/dto/track_playback_bundle_dto.dart';
import 'package:software_project/features/playback_streaming_engine/data/mapper/playback_mapper.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';

import '../helpers/playback_test_utils.dart';

void main() {
  test('TrackPlaybackBundleDtoMapper maps rich bundle to entity', () {
    final entity = TrackPlaybackBundleDto.fromJson(
      sampleBundleJson(
        trackId: 'track-1',
        status: 'preview',
        previewEnabled: true,
        scheduledReleaseDate: DateTime.utc(2026, 5, 1).toIso8601String(),
      ),
    ).toEntity();

    expect(entity.trackId, 'track-1');
    expect(entity.playability.status, PlaybackStatus.preview);
    expect(entity.preview.enabled, isTrue);
    expect(entity.scheduledReleaseDate, DateTime.utc(2026, 5, 1));
  });

  test('TrackArtistSummaryDtoMapper keeps canonical display name', () {
    final entity = const TrackArtistSummaryDto(
      id: 'artist-1',
      name: 'DJ Test',
      tier: 'pro',
      username: 'dj_test',
      displayName: 'DJ Test',
      avatarUrl: 'avatar',
    ).toEntity();

    expect(entity.id, 'artist-1');
    expect(entity.name, 'DJ Test');
    expect(entity.tier, 'pro');
  });

  test('TrackEngagementDtoMapper maps counters and flags', () {
    final entity = const TrackEngagementDto(
      likeCount: 1,
      commentCount: 2,
      repostCount: 3,
      isLiked: true,
      isReposted: false,
      isSaved: true,
    ).toEntity();

    expect(entity.likeCount, 1);
    expect(entity.isLiked, isTrue);
    expect(entity.isSaved, isTrue);
  });

  group('PlayabilityStatusDtoMapper', () {
    test('maps statuses and blocked reasons', () {
      final preview = const PlayabilityStatusDto(
        status: 'preview',
        regionBlocked: false,
        tierBlocked: false,
        requiresSubscription: false,
      ).toEntity();
      final blocked = const PlayabilityStatusDto(
        status: 'blocked',
        regionBlocked: false,
        tierBlocked: true,
        requiresSubscription: true,
        blockedReason: 'tier_restricted',
      ).toEntity();
      final unknownReason = const PlayabilityStatusDto(
        status: 'unknown',
        regionBlocked: false,
        tierBlocked: false,
        requiresSubscription: false,
        blockedReason: 'mystery',
      ).toEntity();

      expect(preview.status, PlaybackStatus.preview);
      expect(blocked.blockedReason, BlockedReason.tierRestricted);
      expect(unknownReason.status, PlaybackStatus.blocked);
      expect(unknownReason.blockedReason, isNull);
    });
  });

  test('PreviewInfoDtoMapper maps preview values', () {
    final entity = const PreviewInfoDto(
      enabled: true,
      previewDurationSeconds: 25,
      previewStartSeconds: 5,
    ).toEntity();

    expect(entity.enabled, isTrue);
    expect(entity.previewStartSeconds, 5);
  });

  test('StreamResponseDtoMapper converts to StreamUrl', () {
    final entity = const StreamResponseDto(
      trackId: 'track-9',
      url: 'https://example.com/file.mp3',
      expiresInSeconds: 123,
      format: 'mp3',
    ).toEntity();

    expect(entity.trackId, 'track-9');
    expect(entity.isHls, isFalse);
  });

  group('PlaybackContextResponseDtoMapper', () {
    test('maps repeat values with none fallback', () {
      expect(
        const PlaybackContextResponseDto(
          trackIds: ['track-1'],
          currentIndex: 0,
          shuffle: false,
          repeat: 'one',
        ).toEntity().repeat,
        RepeatMode.one,
      );
      expect(
        const PlaybackContextResponseDto(
          trackIds: ['track-1'],
          currentIndex: 0,
          shuffle: false,
          repeat: 'all',
        ).toEntity().repeat,
        RepeatMode.all,
      );
      expect(
        const PlaybackContextResponseDto(
          trackIds: ['track-1'],
          currentIndex: 0,
          shuffle: false,
          repeat: 'weird',
        ).toEntity().repeat,
        RepeatMode.none,
      );
    });
  });

  group('HistoryTrackDtoMapper', () {
    test('maps history track with parsed dates', () {
      final entity =
          HistoryTrackDto.fromJson(sampleHistoryJson(status: 'preview'))
              .toEntity();

      expect(entity.trackId, 'track-1');
      expect(entity.status, PlaybackStatus.preview);
      expect(entity.releaseDate, DateTime.utc(2026, 3, 1));
    });

    test('falls back gracefully for invalid dates and status', () {
      final entity = HistoryTrackDto.fromJson(const <String, dynamic>{
        'trackId': 'track-2',
        'title': 'Broken',
        'artist': 'Artist',
        'playedAt': 'invalid',
        'durationSeconds': 10,
        'status': 'unknown',
        'releaseDate': 'invalid',
      }).toEntity();

      expect(entity.status, PlaybackStatus.blocked);
      expect(entity.releaseDate, isNull);
      expect(entity.playedAt, isA<DateTime>());
    });
  });
}
