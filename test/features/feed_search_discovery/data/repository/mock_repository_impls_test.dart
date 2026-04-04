import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/feed_search_discovery/data/repository/mock_feed_repository_impl.dart';
import 'package:software_project/features/feed_search_discovery/data/repository/mock_search_repository_impl.dart';
import 'package:software_project/features/feed_search_discovery/data/repository/mock_trending_repository_impl.dart';
import 'package:software_project/features/feed_search_discovery/data/services/mock_feed_service.dart';
import 'package:software_project/features/feed_search_discovery/data/services/mock_search_service.dart';
import 'package:software_project/features/feed_search_discovery/data/services/mock_trending_service.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/album_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_actor_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_source.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/genre_detail_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/playlist_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/profile_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/search_all_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/search_filters_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/search_genre_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/top_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_interaction_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_preview_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/trending_genre_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/trending_track_entity.dart';

import 'mock_repository_impls_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MockFeedService>(),
  MockSpec<MockSearchService>(),
  MockSpec<MockTrendingService>(),
])
void main() {
  final feedItem = FeedItemEntity(
    source: FeedItemSource.post,
    timeAgo: '1h',
    actor: const FeedActorEntity(id: 'actor-1', username: 'Drake'),
    track: TrackPreviewEntity(
      trackId: 'track-1',
      title: 'Track 1',
      artistId: 'artist-1',
      artistName: 'Artist 1',
      artistVerified: true,
      duration: 200,
      likesCount: 100,
      repostsCount: 10,
      commentsCount: 5,
      createdAt: '5:20',
      interaction: TrackInteractionEntity(
        isLiked: true,
        isReposted: false,
      ),
    ),
  );

  const allResult = SearchAllResultEntity(
    topResult: TopResultEntity(
      id: 'track-1',
      type: TopResultType.track,
      title: 'Track 1',
      subtitle: 'Artist 1',
    ),
    tracks: [
      TrackResultEntity(
        id: 'track-1',
        title: 'Track 1',
        artistName: 'Artist 1',
        durationSeconds: 200,
      ),
    ],
  );
  const trackResults = [
    TrackResultEntity(
      id: 'track-2',
      title: 'Track 2',
      artistName: 'Artist 2',
      durationSeconds: 180,
    ),
  ];
  const profileResults = [
    ProfileResultEntity(
      id: 'profile-1',
      username: 'Artist 2',
      followersCount: 1000,
    ),
  ];
  const playlistResults = [
    PlaylistResultEntity(
      id: 'playlist-1',
      title: 'Playlist',
      creatorName: 'Creator',
      trackCount: 3,
    ),
  ];
  const albumResults = [
    AlbumResultEntity(
      id: 'album-1',
      title: 'Album',
      artistName: 'Artist',
      trackCount: 7,
    ),
  ];
  const genres = [
    SearchGenreEntity(id: 'rock', label: 'Rock', colorValue: 0xFFFF3D2E),
  ];
  const genreDetailTrack = TrackResultEntity(
    id: 'track-2',
    title: 'Track 2',
    artistName: 'Artist 2',
    durationSeconds: 180,
  );
  const genreDetail = GenreDetailEntity(
    genreId: 'rock',
    genreLabel: 'Rock',
    trendingTracks: [genreDetailTrack],
  );
  final trendingGenre = TrendingGenreEntity(
    genre: 'Pop',
    tracks: [
      TrendingTrackEntity(
        trackId: 'trend-1',
        title: 'Trend 1',
        artistName: 'Artist 1',
        isLiked: false,
        isReposted: false,
      ),
    ],
  );

  group('MockFeedRepositoryImpl', () {
    late MockMockFeedService service;
    late MockFeedRepositoryImpl repository;

    setUp(() {
      service = MockMockFeedService();
      repository = MockFeedRepositoryImpl(service);
    });

    test('delegates following feed to service', () async {
      when(service.getFollowingFeed()).thenAnswer((_) async => [feedItem]);

      final result = await repository.getFollowingFeed(page: 4, limit: 9);

      expect(result, [feedItem]);
      verify(service.getFollowingFeed()).called(1);
      verifyNever(service.getDiscoverFeed());
    });

    test('delegates discover feed to service', () async {
      when(service.getDiscoverFeed()).thenAnswer((_) async => [feedItem]);

      final result = await repository.getDiscoverFeed(page: 2, limit: 5);

      expect(result, [feedItem]);
      verify(service.getDiscoverFeed()).called(1);
      verifyNever(service.getFollowingFeed());
    });
  });

  group('MockTrendingRepositoryImpl', () {
    late MockMockTrendingService service;
    late MockTrendingRepositoryImpl repository;

    setUp(() {
      service = MockMockTrendingService();
      repository = MockTrendingRepositoryImpl(service);
    });

    test('delegates getTrending to service with genre', () async {
      when(
        service.getTrendingByGenre(genre: 'pop'),
      ).thenAnswer((_) async => trendingGenre);

      final result = await repository.getTrending(genre: 'pop');

      expect(result, trendingGenre);
      verify(service.getTrendingByGenre(genre: 'pop')).called(1);
    });
  });

  group('MockSearchRepositoryImpl', () {
    late MockMockSearchService service;
    late MockSearchRepositoryImpl repository;

    setUp(() {
      service = MockMockSearchService();
      repository = MockSearchRepositoryImpl(service);
    });

    test('delegates searchAll', () async {
      when(service.searchAll('don')).thenAnswer((_) async => allResult);

      final result = await repository.searchAll('don');

      expect(result, allResult);
      verify(service.searchAll('don')).called(1);
    });

    test('delegates searchTracks with paging but ignores filters in service call', () async {
      const filters = TrackSearchFilters(tag: 'rock');
      when(
        service.searchTracks('don', page: 3, limit: 10),
      ).thenAnswer((_) async => trackResults);

      final result = await repository.searchTracks(
        'don',
        page: 3,
        limit: 10,
        filters: filters,
      );

      expect(result, trackResults);
      verify(service.searchTracks('don', page: 3, limit: 10)).called(1);
    });

    test('delegates searchProfiles with paging and filters passthrough boundary', () async {
      const filters = PeopleSearchFilters(location: 'Cairo');
      when(
        service.searchProfiles('artist', page: 2, limit: 8),
      ).thenAnswer((_) async => profileResults);

      final result = await repository.searchProfiles(
        'artist',
        page: 2,
        limit: 8,
        filters: filters,
      );

      expect(result, profileResults);
      verify(service.searchProfiles('artist', page: 2, limit: 8)).called(1);
    });

    test('delegates searchPlaylists and searchAlbums', () async {
      when(
        service.searchPlaylists('mix', page: 1, limit: 20),
      ).thenAnswer((_) async => playlistResults);
      when(
        service.searchAlbums('mix', page: 4, limit: 6),
      ).thenAnswer((_) async => albumResults);

      final playlists = await repository.searchPlaylists('mix');
      final albums = await repository.searchAlbums('mix', page: 4, limit: 6);

      expect(playlists, playlistResults);
      expect(albums, albumResults);
      verify(service.searchPlaylists('mix', page: 1, limit: 20)).called(1);
      verify(service.searchAlbums('mix', page: 4, limit: 6)).called(1);
    });

    test('delegates getGenres and getGenreDetail', () async {
      when(service.getGenres()).thenAnswer((_) async => genres);
      when(
        service.getGenreDetail('rock'),
      ).thenAnswer((_) async => genreDetail);

      final genresResult = await repository.getGenres();
      final detailResult = await repository.getGenreDetail('rock');

      expect(genresResult, genres);
      expect(detailResult, genreDetail);
      verify(service.getGenres()).called(1);
      verify(service.getGenreDetail('rock')).called(1);
    });
  });
}
