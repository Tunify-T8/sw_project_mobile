import 'dart:async';
import 'dart:math';

/// In-memory fake implementation of all streaming operations
/// Simulates realistic network behavior
/// No real HTTP calls 
class MockPlayerService {
  MockPlayerService();

  // ---------------------------------------------------------------------------
  // In-memory state
  // ---------------------------------------------------------------------------

  /// Fake listening history — grows as reportPlaybackEvent is called.
  final List<Map<String, dynamic>> _history = [];

  final _rng = Random();

  // ---------------------------------------------------------------------------
  // 5.1  getPlaybackBundle   as per backend docs
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getPlaybackBundle(
    String trackId, {
    String? privateToken,
  }) async {
    await _delay(350);

    // Simulate a blocked track when id contains 'blocked'
    final isBlocked = trackId.contains('blocked');
    final isPreview = trackId.contains('preview');

    return {
      'trackId': trackId,
      'title': _fakeTitles[_rng.nextInt(_fakeTitles.length)],
      'artist': {
        'id': 'artist_mock_001',
        'name': 'Mock Artist',
        'tier': 'pro',
      },
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

  // ---------------------------------------------------------------------------
  // 5.2  requestStreamUrl
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // 5.3  reportPlaybackEvent
  // ---------------------------------------------------------------------------
  Future<void> reportPlaybackEvent({
    required String trackId,
    required String action,
    required int positionSeconds,
  }) async {
    await _delay(80);

    if (action == 'play') {
      // Add to fake history if not already there for this session
      final alreadyInHistory =
          _history.any((e) => e['trackId'] == trackId);
      if (!alreadyInHistory) {
        _history.insert(0, {
          'trackId': trackId,
          'title': _fakeTitles[_rng.nextInt(_fakeTitles.length)],
          'artist': {
            'id': 'artist_mock_001',
            'name': 'Mock Artist',
            'tier': 'pro',
          },
          'playedAt': DateTime.now().toIso8601String(),
          'durationSeconds': 200,
          'status': 'playable',
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 5.4  buildPlaybackQueue
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> buildPlaybackQueue({
    required String contextType,
    required String contextId,
    String? startTrackId,
    bool shuffle = false,
    String repeat = 'none',
  }) async {
    await _delay(250);

    // Generate 5 fake track IDs for the queue
    final trackIds = List.generate(
      5,
      (i) => 'mock_track_${contextId}_$i',
    );

    // If startTrackId is given and not in the list, insert it at front
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

  // ---------------------------------------------------------------------------
  // 5.5  getListeningHistory
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getListeningHistory({
    int page = 1,
    int limit = 20,
  }) async {
    await _delay(300);

    // Seed some history if empty
    if (_history.isEmpty) {
      for (var i = 0; i < 10; i++) {
        _history.add({
          'trackId': 'history_track_$i',
          'title': _fakeTitles[i % _fakeTitles.length],
          'artist': {
            'id': 'artist_mock_00$i',
            'name': 'Mock Artist $i',
            'tier': i % 3 == 0 ? 'pro' : 'free',
          },
          'playedAt': DateTime.now()
              .subtract(Duration(hours: i * 2))
              .toIso8601String(),
          'durationSeconds': 180 + i * 10,
          'status': 'playable',
        });
      }
    }

    final offset = (page - 1) * limit;
    final paged = _history.skip(offset).take(limit).toList();

    return {
      'data': paged,
      'meta': {
        'page': page,
        'limit': limit,
        'total': _history.length,
      },
    };
  }

  // ---------------------------------------------------------------------------
  // Helpers  
  // ---------------------------------------------------------------------------
  Future<void> _delay(int milliseconds) =>
      Future.delayed(Duration(milliseconds: milliseconds));

  static const _fakeTitles = [
    'Midnight Drive',
    'Electric Soul',
    'Lost in Bass',
    'Golden Hour',
    'Fade to Blue',
    'Neon Lights',
    'Echo Chamber',
    'Broken Clocks',
    'Summer Static',
    'Rainy Season',
  ];
}
