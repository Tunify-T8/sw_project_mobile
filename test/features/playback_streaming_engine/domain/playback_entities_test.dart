import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/offline_play_record.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playability_info.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_context_request.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_event.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_queue.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/player_seed_track.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/preview_info.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/stream_url.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/track_artist_summary.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/track_engagement.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/track_playback_bundle.dart';

void main() {
  group('OfflinePlayRecord', () {
    test('marks completion and round-trips json', () {
      final playedAt = DateTime.utc(2026, 4, 4, 20, 30);
      final record = OfflinePlayRecord(
        trackId: 'track-1',
        playedAt: playedAt,
      );

      final completed = record.markCompleted();
      final restored = OfflinePlayRecord.fromJson(completed.toJson());

      expect(completed.completed, isTrue);
      expect(restored.trackId, 'track-1');
      expect(restored.playedAt, playedAt);
      expect(restored.completed, isTrue);
    });
  });

  group('PlayabilityInfo', () {
    test('exposes state helpers', () {
      const playable = PlayabilityInfo(
        status: PlaybackStatus.playable,
        regionBlocked: false,
        tierBlocked: false,
        requiresSubscription: false,
      );
      const preview = PlayabilityInfo(
        status: PlaybackStatus.preview,
        regionBlocked: false,
        tierBlocked: false,
        requiresSubscription: false,
      );
      const blocked = PlayabilityInfo(
        status: PlaybackStatus.blocked,
        regionBlocked: true,
        tierBlocked: false,
        requiresSubscription: false,
        blockedReason: BlockedReason.regionRestricted,
      );

      expect(playable.canPlayFull, isTrue);
      expect(preview.isPreviewOnly, isTrue);
      expect(blocked.isBlocked, isTrue);
      expect(blocked.blockedReason, BlockedReason.regionRestricted);
    });
  });

  group('PlaybackQueue', () {
    test('resolves currentTrackId defensively and supports copyWith', () {
      const queue = PlaybackQueue(
        trackIds: ['track-1', 'track-2', 'track-3'],
        currentIndex: 1,
        shuffle: false,
        repeat: RepeatMode.none,
      );

      expect(queue.currentTrackId, 'track-2');
      expect(
        queue.copyWith(currentIndex: 2, shuffle: true, repeat: RepeatMode.all),
        isA<PlaybackQueue>(),
      );
      expect(
        const PlaybackQueue(
          trackIds: ['track-1'],
          currentIndex: 9,
          shuffle: false,
          repeat: RepeatMode.none,
        ).currentTrackId,
        isNull,
      );
      expect(
        const PlaybackQueue(
          trackIds: [],
          currentIndex: 0,
          shuffle: false,
          repeat: RepeatMode.none,
        ).currentTrackId,
        isNull,
      );
    });
  });

  group('PlayerSeedTrack', () {
    test('builds playback bundle fallback data', () {
      const seed = PlayerSeedTrack(
        trackId: 'track-1',
        title: 'Night Drive',
        artistName: 'DJ Test',
        durationSeconds: 180,
        coverUrl: 'https://example.com/cover.png',
        waveformUrl: 'https://example.com/waveform.json',
      );

      final bundle = seed.toPlaybackBundle();

      expect(bundle.trackId, 'track-1');
      expect(bundle.artist.name, 'DJ Test');
      expect(bundle.playability.status, PlaybackStatus.playable);
      expect(bundle.preview.enabled, isFalse);
      expect(bundle.engagement.likeCount, 0);
    });

    test('can carry a local region-blocked playability override', () {
      const seed = PlayerSeedTrack(
        trackId: 'blocked-track',
        title: 'Blocked',
        artistName: 'Artist',
        durationSeconds: 180,
        playability: PlayabilityInfo(
          status: PlaybackStatus.blocked,
          regionBlocked: true,
          tierBlocked: false,
          requiresSubscription: false,
          blockedReason: BlockedReason.regionRestricted,
        ),
      );

      final bundle = seed.toPlaybackBundle();

      expect(bundle.playability.status, PlaybackStatus.blocked);
      expect(bundle.playability.regionBlocked, isTrue);
      expect(
        bundle.playability.blockedReason,
        BlockedReason.regionRestricted,
      );
    });

    test('infers direct stream formats and ignores blank urls', () {
      const wavSeed = PlayerSeedTrack(
        trackId: 'wav',
        title: 'Wav',
        artistName: 'Artist',
        durationSeconds: 60,
        directAudioUrl: 'https://example.com/file.wav',
      );
      const hlsSeed = PlayerSeedTrack(
        trackId: 'hls',
        title: 'Hls',
        artistName: 'Artist',
        durationSeconds: 60,
        directAudioUrl: 'https://example.com/file.m3u8',
      );
      const emptySeed = PlayerSeedTrack(
        trackId: 'empty',
        title: 'Empty',
        artistName: 'Artist',
        durationSeconds: 60,
        directAudioUrl: '  ',
      );

      expect(wavSeed.toDirectStreamUrl()!.format, 'wav');
      expect(hlsSeed.toDirectStreamUrl()!.format, 'hls');
      expect(emptySeed.toDirectStreamUrl(), isNull);
    });
  });

  group('StreamUrl', () {
    test('recognizes hls format', () {
      const hls = StreamUrl(
        trackId: 'track-1',
        url: 'https://example.com/file.m3u8',
        expiresInSeconds: 600,
        format: 'hls',
      );
      const mp3 = StreamUrl(
        trackId: 'track-1',
        url: 'https://example.com/file.mp3',
        expiresInSeconds: 600,
        format: 'mp3',
      );

      expect(hls.isHls, isTrue);
      expect(mp3.isHls, isFalse);
    });
  });

  group('TrackEngagement', () {
    test('copyWith replaces only selected values', () {
      const engagement = TrackEngagement(
        likeCount: 1,
        commentCount: 2,
        repostCount: 3,
        isLiked: false,
        isReposted: false,
        isSaved: false,
      );

      final updated = engagement.copyWith(isLiked: true, repostCount: 9);

      expect(updated.likeCount, 1);
      expect(updated.repostCount, 9);
      expect(updated.isLiked, isTrue);
      expect(updated.isSaved, isFalse);
    });
  });

  group('TrackPlaybackBundle', () {
    test('copyWith keeps unspecified values', () {
      const bundle = TrackPlaybackBundle(
        trackId: 'track-1',
        title: 'Night Drive',
        artist: TrackArtistSummary(id: 'artist-1', name: 'DJ Test'),
        durationSeconds: 180,
        waveformUrl: 'waveform',
        coverUrl: 'cover',
        contentWarning: false,
        engagement: TrackEngagement(
          likeCount: 1,
          commentCount: 2,
          repostCount: 3,
          isLiked: false,
          isReposted: false,
          isSaved: false,
        ),
        playability: PlayabilityInfo(
          status: PlaybackStatus.playable,
          regionBlocked: false,
          tierBlocked: false,
          requiresSubscription: false,
        ),
        preview: PreviewInfo(
          enabled: false,
          previewDurationSeconds: 30,
          previewStartSeconds: 0,
        ),
      );

      final updated = bundle.copyWith(title: 'Remix');

      expect(updated.title, 'Remix');
      expect(updated.trackId, 'track-1');
      expect(updated.artist.name, 'DJ Test');
    });
  });

  test('simple entity constructors preserve values', () {
    const request = PlaybackContextRequest(
      contextType: PlaybackContextType.playlist,
      contextId: 'playlist-1',
      startTrackId: 'track-2',
      shuffle: true,
      repeat: RepeatMode.one,
    );
    const event = PlaybackEvent(
      trackId: 'track-9',
      action: PlaybackAction.pause,
      positionSeconds: 42,
    );
    const preview = PreviewInfo(
      enabled: true,
      previewDurationSeconds: 15,
      previewStartSeconds: 7,
    );
    const artist = TrackArtistSummary(
      id: 'artist-1',
      name: 'DJ Test',
      username: 'dj_test',
      displayName: 'DJ Test',
      avatarUrl: 'avatar',
      tier: 'pro',
    );

    expect(request.contextType, PlaybackContextType.playlist);
    expect(request.repeat, RepeatMode.one);
    expect(event.action, PlaybackAction.pause);
    expect(preview.previewStartSeconds, 7);
    expect(artist.username, 'dj_test');
  });
}
