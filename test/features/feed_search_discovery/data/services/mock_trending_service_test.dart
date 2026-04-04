import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/data/services/mock_trending_service.dart';

void main() {
  late MockTrendingService service;

  setUp(() {
    service = MockTrendingService();
  });

  test('returns seeded pop tracks', () async {
    final result = await service.getTrendingByGenre(genre: 'pop');

    expect(result.genre, 'Pop');
    expect(result.tracks, hasLength(5));
    expect(result.tracks.first.title, 'Midnight Echo');
  });

  test('matches genres case-insensitively and returns empty fallback for unknown genre', () async {
    final hipHop = await service.getTrendingByGenre(genre: 'HIP HOP & RAP');
    final unknown = await service.getTrendingByGenre(genre: 'ambient');

    expect(hipHop.genre, 'Hip Hop & Rap');
    expect(hipHop.tracks, hasLength(2));
    expect(unknown.genre, 'ambient');
    expect(unknown.tracks, isEmpty);
  });

  test('returns seeded jazz and electronic tracks', () async {
    final jazz = await service.getTrendingByGenre(genre: 'jazz');
    final electronic = await service.getTrendingByGenre(genre: 'electronic');

    expect(jazz.genre, 'Jazz');
    expect(jazz.tracks, hasLength(3));
    expect(jazz.tracks.first.isReposted, isTrue);
    expect(electronic.genre, 'Electronic');
    expect(electronic.tracks, hasLength(3));
    expect(electronic.tracks.first.isLiked, isTrue);
  });

  test('returns seeded rock and soul tracks', () async {
    final rock = await service.getTrendingByGenre(genre: 'rock, metal, punk');
    final soul = await service.getTrendingByGenre(genre: 'soul');

    expect(rock.genre, 'Rock, Metal, Punk');
    expect(rock.tracks, hasLength(2));
    expect(rock.tracks[1].isReposted, isTrue);
    expect(soul.genre, 'Soul');
    expect(soul.tracks, hasLength(2));
    expect(soul.tracks.first.title, 'Golden Hour');
  });
}
