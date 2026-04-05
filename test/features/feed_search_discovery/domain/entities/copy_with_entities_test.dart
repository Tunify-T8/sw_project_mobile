import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/collection_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/collection_type.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/discovery_item_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_actor_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_source.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/resource_type.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_interaction_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_preview_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/trending_genre_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/trending_track_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/user_preview_entity.dart';

void main() {
  final interaction = TrackInteractionEntity(isLiked: true, isReposted: false);
  final trackPreview = TrackPreviewEntity(
    trackId: 'track-1',
    title: 'Ocean Drive',
    artistId: 'artist-1',
    artistName: 'Duke',
    artistAvatar: 'avatar',
    artistVerified: true,
    isFollowingArtist: false,
    coverUrl: 'cover',
    duration: 210,
    listensCount: 12,
    likesCount: 3,
    repostsCount: 4,
    commentsCount: 5,
    createdAt: '10:30',
    interaction: interaction,
  );
  final collection = CollectionEntity(
    id: 'collection-1',
    type: CollectionType.playlist,
    title: 'Party Mix',
    creatorId: 'creator-1',
    creatorName: 'Curator',
    coverUrl: 'cover',
    trackCount: 7,
    duration: 3600,
    releaseYear: 2025,
    createdAt: DateTime(2025, 1, 1),
  );
  final user = UserPreviewEntity(
    id: 'user-1',
    username: 'Nova',
    avatarUrl: 'avatar',
    followersCount: 1000,
    verified: true,
    location: 'Cairo',
    isFollowing: false,
  );
  final feedItem = FeedItemEntity(
    source: FeedItemSource.repost,
    timeAgo: '3h ago',
    track: trackPreview,
    actor: FeedActorEntity(id: 'actor-1', username: 'Poster', avatarUrl: 'a'),
  );
  final trendingTrack = TrendingTrackEntity(
    trackId: 'trend-1',
    title: 'Midnight Echo',
    artistName: 'Luna',
    coverUrl: 'cover',
    isLiked: false,
    isReposted: true,
  );

  group('copyWith entities', () {
    test('UserPreviewEntity copyWith updates supplied values and keeps others', () {
      final updated = user.copyWith(username: 'Sky', location: 'Giza');
      final preserved = user.copyWith(id: 'user-2');

      expect(updated.username, 'Sky');
      expect(updated.location, 'Giza');
      expect(updated.id, user.id);
      expect(updated.verified, isTrue);
      expect(preserved.id, 'user-2');
      expect(preserved.verified, user.verified);
      expect(preserved.location, user.location);
    });

    test('TrendingTrackEntity copyWith updates fields and preserves old ones', () {
      final updated = trendingTrack.copyWith(
        title: 'Neon Dreams',
        isLiked: true,
      );
      final preserved = trendingTrack.copyWith(trackId: 'trend-2');

      expect(updated.title, 'Neon Dreams');
      expect(updated.isLiked, isTrue);
      expect(updated.trackId, trendingTrack.trackId);
      expect(updated.isReposted, isTrue);
      expect(preserved.trackId, 'trend-2');
      expect(preserved.title, trendingTrack.title);
      expect(preserved.isLiked, trendingTrack.isLiked);
      expect(preserved.isReposted, trendingTrack.isReposted);
    });

    test('TrendingGenreEntity copyWith swaps genre and tracks', () {
      final original = TrendingGenreEntity(
        genre: 'Pop',
        tracks: [trendingTrack],
      );
      final updated = original.copyWith(
        genre: 'Jazz',
        tracks: const [],
      );
      final preserved = original.copyWith();

      expect(updated.genre, 'Jazz');
      expect(updated.tracks, isEmpty);
      expect(preserved.genre, 'Pop');
      expect(preserved.tracks, [trendingTrack]);
    });

    test('DiscoveryItemEntity copyWith updates each optional resource branch', () {
      final original = DiscoveryItemEntity(
        itemType: ResourceType.track,
        track: trackPreview,
      );
      final updated = original.copyWith(
        itemType: ResourceType.collection,
        collection: collection,
        user: user,
      );
      final preserved = original.copyWith(collection: collection);

      expect(updated.itemType, ResourceType.collection);
      expect(updated.track, trackPreview);
      expect(updated.collection, collection);
      expect(updated.user, user);
      expect(preserved.itemType, ResourceType.track);
      expect(preserved.user, isNull);
    });

    test('TrackInteractionEntity copyWith updates booleans', () {
      final updated = interaction.copyWith(isLiked: false, isReposted: true);
      final preserved = interaction.copyWith(isLiked: false);

      expect(updated.isLiked, isFalse);
      expect(updated.isReposted, isTrue);
      expect(preserved.isReposted, interaction.isReposted);
    });

    test('FeedItemEntity copyWith updates source timeAgo track and actor', () {
      final newActor = FeedActorEntity(id: 'actor-2', username: 'Other');
      final updated = feedItem.copyWith(
        source: FeedItemSource.post,
        postedAt: 'ignored',
        timeAgo: '1m ago',
        track: trackPreview.copyWith(title: 'Other Song'),
        actor: newActor,
      );
      final preserved = feedItem.copyWith(source: FeedItemSource.post);

      expect(updated.source, FeedItemSource.post);
      expect(updated.timeAgo, '1m ago');
      expect(updated.track.title, 'Other Song');
      expect(updated.actor, newActor);
      expect(preserved.timeAgo, feedItem.timeAgo);
    });

    test('TrackPreviewEntity copyWith updates optional and numeric fields', () {
      final updated = trackPreview.copyWith(
        trackId: 'track-2',
        title: 'Changed',
        artistId: 'artist-2',
        artistName: 'Nova',
        artistAvatar: null,
        artistVerified: false,
        isFollowingArtist: true,
        coverUrl: null,
        duration: 99,
        listensCount: null,
        likesCount: 30,
        repostsCount: 40,
        commentsCount: 50,
        createdAt: '9:00',
        interaction: TrackInteractionEntity(
          isLiked: false,
          isReposted: true,
        ),
      );
      final preserved = trackPreview.copyWith(trackId: 'track-3');

      expect(updated.trackId, 'track-2');
      expect(updated.artistName, 'Nova');
      expect(updated.artistAvatar, trackPreview.artistAvatar);
      expect(updated.coverUrl, trackPreview.coverUrl);
      expect(updated.likesCount, 30);
      expect(updated.interaction.isReposted, isTrue);
      expect(preserved.trackId, 'track-3');
      expect(preserved.artistId, trackPreview.artistId);
      expect(preserved.listensCount, trackPreview.listensCount);
    });

    test('CollectionEntity copyWith updates type and metadata', () {
      final updated = collection.copyWith(
        type: CollectionType.album,
        title: 'Night Drive',
        creatorName: 'Artist',
        trackCount: 10,
        duration: 4000,
        releaseYear: 2026,
      );
      final preserved = collection.copyWith(type: CollectionType.album);

      expect(updated.type, CollectionType.album);
      expect(updated.title, 'Night Drive');
      expect(updated.creatorName, 'Artist');
      expect(updated.trackCount, 10);
      expect(updated.releaseYear, 2026);
      expect(updated.createdAt, collection.createdAt);
      expect(preserved.creatorId, collection.creatorId);
    });
  });
}
