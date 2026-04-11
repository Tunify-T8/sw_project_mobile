import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/feed_search_discovery/data/api/discovery_api.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/collection_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/collection_search_response_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/search_result_item_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/track_interaction_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/track_preview_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/track_search_response_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/trending_item_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/user_preview_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/user_search_response_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/repository/real_search_repository_impl.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/collection_type.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/search_filters_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/top_result_entity.dart';

import 'real_search_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DiscoveryApi>()])
void main() {
  late MockDiscoveryApi api;
  late RealSearchRepositoryImpl repository;

  setUp(() {
    api = MockDiscoveryApi();
    repository = RealSearchRepositoryImpl(api);
  });

  group('searchAll', () {
    test('maps track, album, playlist, and profile results and prefers first track as top result', () async {
      final response = PaginatedSearchResponseDto(
        items: [
          SearchResultItemDto.fromJson({
            'type': 'track',
            'id': 'track-1',
            'title': 'Ocean Drive',
            'artist': 'Duke',
            'durationSeconds': 180,
            'coverUrl': 'https://example.com/track.jpg',
            'likesCount': 100,
            'playsCount': 1234,
            'allowDownloads': true,
            'createdAt': '2026-01-01T00:00:00Z',
            'score': 0.9,
          }),
          SearchResultItemDto.fromJson({
            'type': 'album',
            'id': 'album-1',
            'title': 'OCTANE',
            'artist': 'Don Toliver',
            'trackPreview': [
              {
                'id': 't1',
                'title': 'Song',
                'artist': 'Don Toliver',
                'durationSeconds': 200,
              },
            ],
            'createdAt': '2026-01-01T00:00:00Z',
            'score': 0.8,
          }),
          SearchResultItemDto.fromJson({
            'type': 'playlist',
            'id': 'playlist-1',
            'title': 'Workout',
            'artist': 'Curator',
            'trackPreview': [
              {
                'id': 't2',
                'title': 'Track',
                'artist': 'Artist',
                'durationSeconds': 180,
              },
              {
                'id': 't3',
                'title': 'Track 2',
                'artist': 'Artist',
                'durationSeconds': 190,
              },
            ],
            'createdAt': '2026-01-01T00:00:00Z',
            'score': 0.7,
          }),
          SearchResultItemDto.fromJson({
            'type': 'user',
            'id': 'user-1',
            'username': 'Don Toliver',
            'location': 'United States',
            'isCertified': true,
            'followersCount': 688000,
            'isFollowing': true,
            'score': 0.95,
          }),
        ],
        page: 1,
        limit: 20,
        total: 4,
        hasMore: false,
      );
      when(api.search(q: 'don', page: 1, limit: 20)).thenAnswer((_) async => response);

      final result = await repository.searchAll('don');

      expect(result.tracks, hasLength(1));
      expect(result.tracks.first.playCount, '1.2K');
      expect(result.albums.single.trackCount, 1);
      expect(result.playlists.single.trackCount, 2);
      expect(result.profiles.single.isVerified, isTrue);
      expect(result.profiles.single.isFollowing, isTrue);
      expect(result.topResult?.type, TopResultType.track);
      expect(result.topResult?.title, 'Ocean Drive');
      verify(api.search(q: 'don', page: 1, limit: 20)).called(1);
    });

    test('uses profile as top result and formats followers when there are no tracks', () async {
      final response = PaginatedSearchResponseDto(
        items: [
          SearchResultItemDto.fromJson({
            'type': 'user',
            'id': 'user-1',
            'username': 'Artist',
            'followersCount': 1500,
            'isCertified': false,
            'score': 0.9,
          }),
        ],
        page: 1,
        limit: 20,
        total: 1,
        hasMore: false,
      );
      when(api.search(q: 'artist', page: 1, limit: 20)).thenAnswer((_) async => response);

      final result = await repository.searchAll('artist');

      expect(result.topResult?.type, TopResultType.profile);
      expect(result.topResult?.subtitle, '1.5K followers');
    });
  });

  group('tab-specific search', () {
    test('searchTracks forwards filters to api and maps counts', () async {
      const filters = TrackSearchFilters(
        tag: 'rock',
        timeAdded: TrackTimeAdded.pastWeek,
        duration: TrackDuration.twoToTen,
        toListen: TrackLicense.shareable,
        allowDownloads: true,
      );
      final response = TrackSearchResponseDto(
        items: [
          TrackPreviewDto(
            trackId: 'track-1',
            title: 'Ocean Drive',
            artistId: 'artist-1',
            artistName: 'Duke',
            artistAvatar: null,
            artistVerified: true,
            isFollowingArtist: false,
            coverUrl: null,
            duration: 180,
            likesCount: 20500,
            repostsCount: 0,
            commentsCount: 0,
            createdAt: '2026-01-01T00:00:00Z',
            interaction: TrackInteractionDto(
              isLiked: false,
              isReposted: false,
            ),
          ),
        ],
        page: 1,
        limit: 20,
        total: 1,
      );
      when(
        api.searchTracks(
          q: 'ocean',
          page: 2,
          limit: 5,
          tag: 'rock',
          timeAdded: 'PAST_WEEK',
          duration: 'TWO_TEN',
          toListen: 'shareable',
          allowDownloads: true,
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.searchTracks(
        'ocean',
        page: 2,
        limit: 5,
        filters: filters,
      );

      expect(result.single.title, 'Ocean Drive');
      expect(result.single.playCount, '20.5K');
      verify(
        api.searchTracks(
          q: 'ocean',
          page: 2,
          limit: 5,
          tag: 'rock',
          timeAdded: 'PAST_WEEK',
          duration: 'TWO_TEN',
          toListen: 'shareable',
          allowDownloads: true,
        ),
      ).called(1);
    });

    test('searchProfiles forwards people filters and maps user preview', () async {
      const filters = PeopleSearchFilters(
        location: 'Cairo',
        minFollowers: 500,
        verifiedOnly: true,
        sort: PeopleSort.followers,
      );
      final response = UserSearchResponseDto(
        items: [
          UserPreviewDto(
            id: 'user-1',
            username: 'Artist',
            avatarUrl: 'https://example.com/avatar.jpg',
            followersCount: 900,
            verified: true,
            location: 'Cairo',
            isFollowing: true,
          ),
        ],
        page: 1,
        limit: 20,
        total: 1,
      );
      when(
        api.searchPeople(
          q: 'artist',
          page: 3,
          limit: 4,
          location: 'Cairo',
          minFollowers: 500,
          verifiedOnly: true,
          sort: 'FOLLOWERS',
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.searchProfiles(
        'artist',
        page: 3,
        limit: 4,
        filters: filters,
      );

      expect(result.single.username, 'Artist');
      expect(result.single.isVerified, isTrue);
      expect(result.single.isFollowing, isTrue);
      verify(
        api.searchPeople(
          q: 'artist',
          page: 3,
          limit: 4,
          location: 'Cairo',
          minFollowers: 500,
          verifiedOnly: true,
          sort: 'FOLLOWERS',
        ),
      ).called(1);
    });

    test('searchPlaylists and searchAlbums filter collection types and map creator fields', () async {
      final response = CollectionSearchResponseDto(
        items: [
          CollectionDto(
            id: 'playlist-1',
            type: CollectionType.playlist,
            title: 'Party Mix',
            creatorId: 'creator-1',
            creatorName: 'DJ',
            coverUrl: null,
            trackCount: 6,
            duration: 1000,
            createdAt: '2026-01-01T00:00:00Z',
          ),
          CollectionDto(
            id: 'album-1',
            type: CollectionType.album,
            title: 'OCTANE',
            creatorId: 'creator-2',
            creatorName: 'Don Toliver',
            coverUrl: null,
            trackCount: 12,
            duration: 2000,
            createdAt: '2026-01-01T00:00:00Z',
          ),
        ],
        page: 1,
        limit: 20,
        total: 2,
      );
      when(
        api.searchCollections(q: 'mix', page: 1, limit: 20, tag: 'party'),
      ).thenAnswer((_) async => response);

      final playlists = await repository.searchPlaylists(
        'mix',
        filters: const CollectionSearchFilters(tag: 'party'),
      );
      final albums = await repository.searchAlbums(
        'mix',
        filters: const CollectionSearchFilters(tag: 'party'),
      );

      expect(playlists.single.id, 'playlist-1');
      expect(playlists.single.creatorName, 'DJ');
      expect(albums.single.id, 'album-1');
      expect(albums.single.artistName, 'Don Toliver');
      verify(
        api.searchCollections(q: 'mix', page: 1, limit: 20, tag: 'party'),
      ).called(2);
    });
  });

  group('genre data', () {
    test('getGenres returns static configured genres', () async {
      final genres = await repository.getGenres();

      expect(genres, isNotEmpty);
      expect(genres.first.id, 'hip_hop_rap');
      expect(genres.any((g) => g.id == 'rock'), isTrue);
    });

    test('getGenreDetail combines trending, collections, and profiles', () async {
      when(
        api.getTrending(type: 'track', period: 'week', limit: 10),
      ).thenAnswer(
        (_) async => const PaginatedTrendingResponseDto(
          items: [
            TrendingItemDto(
              id: 'trend-1',
              name: 'Hit Song',
              artist: 'Artist',
              type: 'track',
              score: 10,
            ),
          ],
          type: 'track',
          period: 'week',
        ),
      );
      when(
        api.searchCollections(q: '', tag: 'rock', limit: 10),
      ).thenAnswer(
        (_) async => CollectionSearchResponseDto(
          items: [
            CollectionDto(
              id: 'playlist-1',
              type: CollectionType.playlist,
              title: 'Rock Mix',
              creatorId: 'creator-1',
              creatorName: 'Curator',
              coverUrl: null,
              trackCount: 4,
              duration: 1000,
              createdAt: '2026-01-01T00:00:00Z',
            ),
          ],
          page: 1,
          limit: 10,
          total: 1,
        ),
      );
      when(
        api.searchPeople(q: 'rock', limit: 6),
      ).thenAnswer(
        (_) async => UserSearchResponseDto(
          items: [
            UserPreviewDto(
              id: 'user-1',
              username: 'Rocker',
              avatarUrl: 'https://example.com/rocker.jpg',
              followersCount: 200,
              verified: true,
              location: 'NY',
              isFollowing: false,
            ),
          ],
          page: 1,
          limit: 6,
          total: 1,
        ),
      );

      final result = await repository.getGenreDetail('rock');

      expect(result.genreId, 'rock');
      expect(result.genreLabel, 'rock');
      expect(result.trendingTracks.single.title, 'Hit Song');
      expect(result.playlists.single.title, 'Rock Mix');
      expect(result.profiles.single.username, 'Rocker');
      verify(api.getTrending(type: 'track', period: 'week', limit: 10)).called(1);
      verify(api.searchCollections(q: '', tag: 'rock', limit: 10)).called(1);
      verify(api.searchPeople(q: 'rock', limit: 6)).called(1);
    });
  });
}
