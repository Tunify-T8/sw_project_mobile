part of 'mock_player_service.dart';

extension MockPlayerServiceHistory on MockPlayerService {
  Future<Map<String, dynamic>> getListeningHistory({
    int page = 1,
    int limit = 20,
  }) async {
    await _delay(300);

    if (_history.isEmpty) {
      for (var i = 0; i < 10; i++) {
        _history.add({
          'trackId': 'history_track_$i',
          'title': _fakeTitles[i % _fakeTitles.length],
          'artist': 'Mock Artist $i',
          'coverUrl': 'https://cdn.mock.app/artwork/history_track_$i.png',
          'genre': i.isEven ? 'Hip Hop' : 'Pop',
          'releaseDate': DateTime.now()
              .subtract(Duration(days: i * 3))
              .toIso8601String(),
          'playedAt': DateTime.now()
              .subtract(Duration(hours: i * 2))
              .toIso8601String(),
          'durationSeconds': 180 + i * 10,
          'status': 'playable',
          'engagement': {
            'likeCount': 100 + i * 7,
            'commentCount': 8 + i,
            'repostCount': 3 + i,
            'playCount': 1200 + (i * 430),
          },
        });
      }
    }

    final offset = (page - 1) * limit;
    final paged = _history.skip(offset).take(limit).toList();

    return {
      'data': paged,
      'meta': {'page': page, 'limit': limit, 'total': _history.length},
    };
  }

  Future<void> _delay(int milliseconds) =>
      Future.delayed(Duration(milliseconds: milliseconds));
}

const _fakeTitles = [
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
