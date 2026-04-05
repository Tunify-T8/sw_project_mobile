import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/collection_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/discovery_item_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/feed_action_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/feed_item_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/track_interaction_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/track_preview_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/trending_item_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/dto/user_preview_dto.dart';
import 'package:software_project/features/feed_search_discovery/data/mappers/collection_mapper.dart';
import 'package:software_project/features/feed_search_discovery/data/mappers/discover_item_mapper.dart';
import 'package:software_project/features/feed_search_discovery/data/mappers/feed_item_mapper.dart';
import 'package:software_project/features/feed_search_discovery/data/mappers/track_interaction_mapper.dart';
import 'package:software_project/features/feed_search_discovery/data/mappers/track_preview_mapper.dart';
import 'package:software_project/features/feed_search_discovery/data/mappers/trending_item_mapper.dart';
import 'package:software_project/features/feed_search_discovery/data/mappers/user_preview_mapper.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/collection_type.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/resource_type.dart';

void main() {
  test('TrackInteractionMapper maps dto flags to entity', () {
    final entity = TrackInteractionDto(
      isLiked: true,
      isReposted: false,
    ).toEntity();

    expect(entity.isLiked, isTrue);
    expect(entity.isReposted, isFalse);
  });

  test('TrackPreviewMapper maps nested interaction and optional fields', () {
    final entity = TrackPreviewDto(
      trackId: 'track-1',
      title: 'Ocean Drive',
      artistId: 'artist-1',
      artistName: 'Duke',
      artistAvatar: 'https://example.com/avatar.jpg',
      artistVerified: true,
      isFollowingArtist: false,
      coverUrl: 'https://example.com/cover.jpg',
      duration: 180,
      likesCount: 10,
      repostsCount: 2,
      commentsCount: 3,
      createdAt: '2026-01-01T00:00:00Z',
      interaction: TrackInteractionDto(isLiked: true, isReposted: true),
    ).toEntity();

    expect(entity.trackId, 'track-1');
    expect(entity.artistAvatar, 'https://example.com/avatar.jpg');
    expect(entity.interaction.isLiked, isTrue);
    expect(entity.interaction.isReposted, isTrue);
  });

  test('CollectionMapper parses createdAt and maps collection fields', () {
    final entity = CollectionDto(
      id: 'collection-1',
      type: CollectionType.playlist,
      title: 'Party Mix',
      creatorId: 'creator-1',
      creatorName: 'DJ',
      coverUrl: 'https://example.com/cover.jpg',
      trackCount: 7,
      duration: 1200,
      releaseYear: 2026,
      createdAt: '2026-01-01T00:00:00Z',
    ).toEntity();

    expect(entity.type, CollectionType.playlist);
    expect(entity.creatorName, 'DJ');
    expect(entity.createdAt.year, 2026);
  });

  test('UserPreviewMapper maps user preview fields', () {
    final entity = UserPreviewDto(
      id: 'user-1',
      username: 'Artist',
      avatarUrl: 'https://example.com/avatar.jpg',
      followersCount: 500,
      verified: true,
      location: 'Cairo',
      isFollowing: false,
    ).toEntity();

    expect(entity.username, 'Artist');
    expect(entity.verified, isTrue);
    expect(entity.location, 'Cairo');
  });

  test('TrendingItemMapper maps dto and defaults social flags to false', () {
    final entity = const TrendingItemDto(
      id: 'trend-1',
      name: 'Neon Dreams',
      artist: 'Skyline',
      coverUrl: 'https://example.com/trend.jpg',
      type: 'track',
      score: 10,
    ).toEntity();

    expect(entity.trackId, 'trend-1');
    expect(entity.title, 'Neon Dreams');
    expect(entity.isLiked, isFalse);
    expect(entity.isReposted, isFalse);
  });

  test('DiscoverItemMapper maps the active union branch only', () {
    final entity = DiscoveryItemDto(
      itemType: ResourceType.user,
      user: UserPreviewDto(
        id: 'user-1',
        username: 'Artist',
        avatarUrl: null,
        followersCount: 100,
        verified: true,
        location: null,
        isFollowing: true,
      ),
    ).toEntity();

    expect(entity.itemType, ResourceType.user);
    expect(entity.user?.username, 'Artist');
    expect(entity.track, isNull);
    expect(entity.collection, isNull);
  });

  test('FeedItemMapper maps source actor track counts and formatted times', () {
    final createdAt = DateTime.now()
        .subtract(const Duration(hours: 2, minutes: 5))
        .toUtc()
        .toIso8601String();
    final entity = FeedItemDto(
      trackId: 'track-1',
      action: FeedActionDto(
        actorId: 'user-1',
        username: 'Drake',
        action: 'repost',
        date: createdAt,
        avatarUrl: 'https://example.com/avatar.jpg',
      ),
      title: 'Midnight Drive',
      artist: 'Drake',
      artistId: 'artist-1',
      artistIsCertified: true,
      genre: 'hip hop',
      durationInSeconds: 215,
      coverUrl: 'https://example.com/cover.jpg',
      waveformUrl: null,
      artistAvatarUrl: 'https://example.com/artist.jpg',
      numberOfComments: 45,
      numberOfLikes: 320,
      numberOfListens: 12400,
      numberOfReposts: 28,
      isLiked: true,
      isReposted: false,
      isFollowingArtist: true,
    ).toEntity();

    expect(entity.source.name, 'repost');
    expect(entity.actor.username, 'Drake');
    expect(entity.track.listensCount, 12400);
    expect(entity.track.createdAt, contains(':'));
    expect(entity.timeAgo, matches(RegExp(r'^\d+[mhdw] ago$')));
  });

  test('FeedItemMapper formats day and week time-ago branches', () {
    FeedItemDto buildDto(DateTime date) => FeedItemDto(
      trackId: 'track-1',
      title: 'Song',
      artistId: 'artist-1',
      artist: 'Artist',
      artistIsCertified: false,
      genre: 'house',
      durationInSeconds: 180,
      numberOfComments: 2,
      numberOfLikes: 20,
      numberOfListens: 10,
      numberOfReposts: 3,
      isLiked: false,
      isReposted: true,
      isFollowingArtist: true,
      action: FeedActionDto(
        action: 'post',
        actorId: 'actor-1',
        username: 'Poster',
        avatarUrl: null,
        date: date.toUtc().toIso8601String(),
      ),
    );

    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    final nineDaysAgo = DateTime.now().subtract(const Duration(days: 9));

    expect(buildDto(threeDaysAgo).toEntity().timeAgo, '3d ago');
    expect(buildDto(nineDaysAgo).toEntity().timeAgo, '1w ago');
  });
}
