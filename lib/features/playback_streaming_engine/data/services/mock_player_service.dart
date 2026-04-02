import 'dart:async';
import 'dart:math';

part 'mock_player_service_history.dart';

/// In-memory fake implementation of all streaming operations.
/// Simulates realistic network behaviour. No real HTTP calls.
class MockPlayerService {
  MockPlayerService();

  /// Fake listening history — grows as reportPlaybackEvent is called.
  final List<Map<String, dynamic>> _history = [];

  /// Cache of bundle data keyed by trackId so history entries use real titles.
  final Map<String, Map<String, dynamic>> _bundleCache =
      <String, Map<String, dynamic>>{};

  final _rng = Random();

  Future<Map<String, dynamic>> getPlaybackBundle(
    String trackId, {
    String? privateToken,
  }) async {
    await _delay(350);

    final isBlocked = trackId.contains('blocked');
    final isPreview = trackId.contains('preview');

    final bundle = {
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

    // Cache so history can use the real title/artist/coverUrl/duration
    _bundleCache[trackId] = bundle;

    return bundle;
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
    // Optional hints passed when the real title/artist are known on the client
    String? title,
    String? artistName,
    String? coverUrl,
    int? durationSeconds,
  }) async {
    await _delay(80);

    if (action == 'play') {
      // Resolve the best available metadata in priority order:
      //   1. Caller-supplied hints (from seedTrack / bundle)
      //   2. Cached bundle data from a previous getPlaybackBundle call
      //   3. Fallback mock data
      final cached = _bundleCache[trackId];
      final resolvedTitle =
          title ??
          (cached?['title'] as String?) ??
          _fakeTitles[_rng.nextInt(_fakeTitles.length)];
      final resolvedArtist = artistName ?? 'Mock Artist';
      final resolvedCover =
          coverUrl ?? 'https://cdn.mock.app/artwork/$trackId.png';
      final resolvedDuration =
          durationSeconds ?? (cached?['durationSeconds'] as int?) ?? 200;

      final existingIndex = _history.indexWhere((e) => e['trackId'] == trackId);
      final previousPlayCount = existingIndex >= 0
          ? (((_history[existingIndex]['engagement']
                        as Map<String, dynamic>?)?['playCount'])
                    as int? ??
                0)
          : 0;

      final entry = {
        'trackId': trackId,
        'title': resolvedTitle,
        'artist': resolvedArtist,
        'coverUrl': resolvedCover,
        'genre': 'Electronic',
        'releaseDate': DateTime.now().toIso8601String(),
        'playedAt': DateTime.now().toIso8601String(),
        'durationSeconds': resolvedDuration,
        'status': 'playable',
        'engagement': {
          'likeCount': 25,
          'commentCount': 4,
          'repostCount': 2,
          'playCount': previousPlayCount + 1,
        },
      };

      if (existingIndex >= 0) {
        // Move to top and update playedAt / playCount
        _history.removeAt(existingIndex);
      }
      _history.insert(0, entry);
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
