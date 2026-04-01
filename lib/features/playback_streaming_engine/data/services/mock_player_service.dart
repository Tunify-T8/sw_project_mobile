import 'dart:async';
import 'dart:math';

part 'mock_player_service_history.dart';

/// In-memory fake implementation of all streaming operations
/// Simulates realistic network behavior
/// No real HTTP calls
class MockPlayerService {
  MockPlayerService();

  /// Fake listening history â€” grows as reportPlaybackEvent is called.
  final List<Map<String, dynamic>> _history = [];

  final _rng = Random();

  Future<Map<String, dynamic>> getPlaybackBundle(
    String trackId, {
    String? privateToken,
  }) async {
    await _delay(350);

    final isBlocked = trackId.contains('blocked');
    final isPreview = trackId.contains('preview');

    return {
      'trackId': trackId,
      'title': _fakeTitles[_rng.nextInt(_fakeTitles.length)],
      'artist': {'id': 'artist_mock_001', 'name': 'Mock Artist', 'tier': 'pro'},
      'durationSeconds': 180 + _rng.nextInt(180),
      'waveformUrl': 'https://cdn.mock.app/waveforms/$trackId.json',
      'coverUrl': 'https://cdn.mock.app/artwork/$trackId.png',
      'contentWarning': false,
      'engagement': {
        'likeCount': 100 + _rng.nextInt(900),
        'commentCount': 10 + _rng.nextInt(90),
        'repostCount': 5 + _rng.nextInt(50),
        'isLiked': false,
        'isReposted': false,
        'isSaved': false,
      },
      'playability': {
        'status': isBlocked
            ? 'blocked'
            : isPreview
            ? 'preview'
            : 'playable',
        'regionBlocked': false,
        'tierBlocked': isBlocked,
        'requiresSubscription': isBlocked,
        'blockedReason': isBlocked ? 'tier_restricted' : null,
      },
      'preview': {
        'enabled': isPreview,
        'previewDurationSeconds': 30,
        'previewStartSeconds': 0,
      },
      'scheduledReleaseDate': null,
    };
  }

  Future<Map<String, dynamic>> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
  }) async {
    await _delay(200);
    return {
      'trackId': trackId,
      'stream': {
        'url':
            'https://cdn.mock.app/stream/$trackId.m3u8?sig=mock_${DateTime.now().millisecondsSinceEpoch}',
        'expiresInSeconds': 600,
        'format': 'hls',
      },
    };
  }

  Future<void> reportPlaybackEvent({
    required String trackId,
    required String action,
    required int positionSeconds,
  }) async {
    await _delay(80);

    if (action == 'play') {
      final alreadyInHistory = _history.any((e) => e['trackId'] == trackId);
      if (!alreadyInHistory) {
        _history.insert(0, {
          'trackId': trackId,
          'title': _fakeTitles[_rng.nextInt(_fakeTitles.length)],
          'artist': 'Mock Artist',
          'coverUrl': 'https://cdn.mock.app/artwork/$trackId.png',
          'genre': 'Electronic',
          'releaseDate': DateTime.now().toIso8601String(),
          'playedAt': DateTime.now().toIso8601String(),
          'durationSeconds': 200,
          'status': 'playable',
          'engagement': {
            'likeCount': 25,
            'commentCount': 4,
            'repostCount': 2,
            'playCount': 1200,
          },
        });
      }
    }
  }

  Future<Map<String, dynamic>> buildPlaybackQueue({
    required String contextType,
    required String contextId,
    String? startTrackId,
    bool shuffle = false,
    String repeat = 'none',
  }) async {
    await _delay(250);

    final trackIds = List.generate(5, (i) => 'mock_track_${contextId}_$i');

    if (startTrackId != null && !trackIds.contains(startTrackId)) {
      trackIds.insert(0, startTrackId);
    }

    final startIndex = startTrackId != null
        ? trackIds.indexOf(startTrackId).clamp(0, trackIds.length - 1)
        : 0;

    return {
      'queue': trackIds.map((id) => {'trackId': id}).toList(),
      'currentIndex': startIndex,
      'shuffle': shuffle,
      'repeat': repeat,
    };
  }
}
