import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/data/services/mock_search_service.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/top_result_entity.dart';

void main() {
  late MockSearchService service;

  setUp(() {
    service = MockSearchService();
  });

  group('searchAll', () {
    test('returns empty aggregate for blank query', () async {
      final result = await service.searchAll('   ');

      expect(result.topResult, isNull);
      expect(result.tracks, isEmpty);
      expect(result.playlists, isEmpty);
      expect(result.profiles, isEmpty);
      expect(result.albums, isEmpty);
    });

    test('prefers matching profile on tied scores and falls back to first profile', () async {
      final exactProfile = await service.searchAll('don toliver');
      final noMatch = await service.searchAll('zzz');

      expect(exactProfile.topResult?.type, TopResultType.profile);
      expect(exactProfile.topResult?.title, 'Don Toliver');
      expect(noMatch.topResult?.type, TopResultType.profile);
      expect(noMatch.topResult?.title, 'Don Toliver');
    });

    test('surfaces album as top result for octane query', () async {
      final result = await service.searchAll('octane');

      expect(result.topResult?.type, TopResultType.album);
      expect(result.topResult?.title, 'OCTANE');
      expect(result.albums, isNotEmpty);
    });

    test('surfaces exact track and playlist matches over weaker candidates', () async {
      final exactTrack = await service.searchAll('ocean (long way)');
      final exactPlaylist = await service.searchAll('octane don toliver album');

      expect(exactTrack.topResult?.type, TopResultType.track);
      expect(exactTrack.topResult?.title, 'Ocean (Long Way)');
      expect(exactPlaylist.topResult?.type, TopResultType.playlist);
      expect(exactPlaylist.topResult?.title, 'OCTANE DON TOLIVER ALBUM');
    });

    test('formats follower counts in top profile subtitle', () async {
      final result = await service.searchAll('don toliver');

      expect(result.topResult?.subtitle, '688K Followers');
    });
  });

  group('tab searches', () {
    test('return empty lists for blank query', () async {
      expect(await service.searchTracks(' '), isEmpty);
      expect(await service.searchProfiles(' '), isEmpty);
      expect(await service.searchPlaylists(' '), isEmpty);
      expect(await service.searchAlbums(' '), isEmpty);
    });

    test('paginate track and playlist results correctly', () async {
      final firstTrackPage = await service.searchTracks('don', page: 1, limit: 2);
      final secondTrackPage = await service.searchTracks('don', page: 2, limit: 2);
      final beyondLastPage = await service.searchTracks('don', page: 99, limit: 2);
      final playlistPage = await service.searchPlaylists('mix', page: 2, limit: 2);

      expect(firstTrackPage, hasLength(2));
      expect(secondTrackPage, hasLength(2));
      expect(beyondLastPage, isEmpty);
      expect(playlistPage, hasLength(2));
      expect(playlistPage.first.id, 'playlist_003');
    });

    test('paginate profiles and albums with exact page boundaries', () async {
      final profilePage = await service.searchProfiles('don', page: 2, limit: 3);
      final albumPage = await service.searchAlbums('octane', page: 2, limit: 3);

      expect(profilePage, hasLength(1));
      expect(profilePage.single.id, 'profile_004');
      expect(albumPage, hasLength(1));
      expect(albumPage.single.id, 'album_004');
    });
  });

  group('genre data', () {
    test('returns configured genres', () async {
      final genres = await service.getGenres();

      expect(genres, isNotEmpty);
      expect(genres.first.id, 'hip_hop_rap');
      expect(genres.any((genre) => genre.id == 'soul'), isTrue);
    });

    test('maps genre ids to labels in genre detail response', () async {
      final known = await service.getGenreDetail('hip_hop_rap');
      final unknown = await service.getGenreDetail('custom-id');

      expect(known.genreLabel, 'Hip Hop & Rap');
      expect(known.trendingTracks, isNotEmpty);
      expect(known.introducingTracks, hasLength(2));
      expect(known.playlists, isNotEmpty);
      expect(known.profiles, hasLength(3));
      expect(known.albums, hasLength(4));
      expect(unknown.genreLabel, 'custom-id');
    });
  });
}
