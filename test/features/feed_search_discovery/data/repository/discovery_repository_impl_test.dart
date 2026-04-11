import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/feed_search_discovery/data/api/discovery_api.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/collection_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/discovery_item_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/feed_action_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/feed_item_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/track_interaction_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/track_preview_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/trending_item_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/user_preview_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/repository/discovery_repository_impl.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/collection_type.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/resource_type.dart';

import 'discovery_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DiscoveryApi>()])
void main() {
  late MockDiscoveryApi api;
  late DiscoveryRepositoryImpl repository;

  setUp(() {
    api = MockDiscoveryApi();
    repository = DiscoveryRepositoryImpl(api);
  });

  group('getFollowingFeed', () {
    test('forwards paging params and maps dto items to feed entities', () async {
      when(
        api.getFollowingFeed(
          page: 2,
          limit: 5,
          includeReposts: false,
          sinceTimestamp: '2026-01-01T00:00:00Z',
        ),
      ).thenAnswer(
        (_) async => PaginatedFeedResponseDto(
          items: [
            FeedItemDto(
              trackId: 'track-1',
              action: FeedActionDto(
                actorId: 'user-1',
                username: 'Drake',
                action: 'post',
                date: DateTime.now()
                    .subtract(const Duration(hours: 2))
                    .toUtc()
                    .toIso8601String(),
                avatarUrl: 'https://example.com/avatar.jpg',
              ),
              title: 'Midnight Drive',
              artist: 'Drake',
              artistId: 'artist-1',
              artistIsCertified: true,
              genre: 'hip hop',
              durationInSeconds: 215,
              coverUrl: 'https://example.com/cover.jpg',
              artistAvatarUrl: 'https://example.com/artist.jpg',
              numberOfComments: 45,
              numberOfLikes: 320,
              numberOfListens: 12400,
              numberOfReposts: 28,
              isLiked: true,
              isReposted: false,
              isFollowingArtist: true,
            ),
          ],
          page: 2,
          limit: 5,
          hasMore: false,
        ),
      );

      final result = await repository.getFollowingFeed(
        page: 2,
        limit: 5,
        includeReposts: false,
        sinceTimestamp: '2026-01-01T00:00:00Z',
      );

      expect(result, hasLength(1));
      expect(result.single.track.title, 'Midnight Drive');
      expect(result.single.actor.username, 'Drake');
      expect(result.single.track.interaction.isLiked, isTrue);
      verify(
        api.getFollowingFeed(
          page: 2,
          limit: 5,
          includeReposts: false,
          sinceTimestamp: '2026-01-01T00:00:00Z',
        ),
      ).called(1);
    });
  });

  group('getDiscover', () {
    test('forwards paging params and maps mixed discovery items', () async {
      when(
        api.getDiscover(page: 3, limit: 4),
      ).thenAnswer(
        (_) async => PaginatedDiscoveryResponseDto(
          items: [
            DiscoveryItemDto(
              itemType: ResourceType.track,
              track: TrackPreviewDto(
                trackId: 'track-1',
                title: 'Track',
                artistId: 'artist-1',
                artistName: 'Artist',
                artistVerified: true,
                isFollowingArtist: false,
                duration: 180,
                likesCount: 10,
                repostsCount: 2,
                commentsCount: 1,
                createdAt: '2026-01-01T00:00:00Z',
                interaction: TrackInteractionDto(
                  isLiked: false,
                  isReposted: true,
                ),
              ),
            ),
            DiscoveryItemDto(
              itemType: ResourceType.collection,
              collection: CollectionDto(
                id: 'collection-1',
                type: CollectionType.playlist,
                title: 'Playlist',
                creatorId: 'creator-1',
                creatorName: 'Curator',
                coverUrl: null,
                trackCount: 5,
                duration: 1000,
                createdAt: '2026-01-01T00:00:00Z',
              ),
            ),
            DiscoveryItemDto(
              itemType: ResourceType.user,
              user: UserPreviewDto(
                id: 'user-1',
                username: 'Artist',
                avatarUrl: null,
                followersCount: 500,
                verified: true,
                location: 'Cairo',
                isFollowing: true,
              ),
            ),
          ],
          page: 3,
          limit: 4,
          total: 3,
        ),
      );

      final result = await repository.getDiscover(page: 3, limit: 4);

      expect(result, hasLength(3));
      expect(result[0].track?.title, 'Track');
      expect(result[1].collection?.title, 'Playlist');
      expect(result[2].user?.username, 'Artist');
      verify(api.getDiscover(page: 3, limit: 4)).called(1);
    });
  });

  group('getTrending', () {
    test('requests weekly track trending by genre and maps track entities', () async {
      when(
        api.getTrending(type: 'track', period: 'week', genreId: 'pop'),
      ).thenAnswer(
        (_) async => const PaginatedTrendingResponseDto(
          items: [
            TrendingItemDto(
              id: 'trend-1',
              name: 'Neon Dreams',
              artist: 'Skyline',
              coverUrl: 'https://example.com/trend.jpg',
              type: 'track',
              score: 10,
            ),
          ],
          type: 'track',
          period: 'week',
        ),
      );

      final result = await repository.getTrending(genre: 'pop');

      expect(result.genre, 'pop');
      expect(result.tracks.single.title, 'Neon Dreams');
      expect(result.tracks.single.isLiked, isFalse);
      expect(result.tracks.single.isReposted, isFalse);
      verify(
        api.getTrending(type: 'track', period: 'week', genreId: 'pop'),
      ).called(1);
    });
  });
}
