import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/collection_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/collection_type.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/discovery_item_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_actor_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_item_source.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/resource_type.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/search_filters_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_interaction_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_preview_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/user_preview_entity.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/feed_state.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/search_provider.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/trending_state.dart';

void main() {
  final interaction = TrackInteractionEntity(isLiked: true, isReposted: false);
  final preview = TrackPreviewEntity(
    trackId: 'track-1',
    title: 'Track',
    artistId: 'artist-1',
    artistName: 'Artist',
    artistVerified: true,
    duration: 180,
    likesCount: 10,
    repostsCount: 2,
    commentsCount: 1,
    createdAt: '5:20',
    interaction: interaction,
  );
  final feedItem = FeedItemEntity(
    source: FeedItemSource.post,
    timeAgo: '2h',
    track: preview,
    actor: const FeedActorEntity(id: 'user-1', username: 'Artist'),
  );

  group('search filters', () {
    test('TrackSearchFilters hasAny copyWith and cleared behave correctly', () {
      const filters = TrackSearchFilters(
        tag: 'rock',
        timeAdded: TrackTimeAdded.pastWeek,
        duration: TrackDuration.twoToTen,
        toListen: TrackLicense.shareable,
        allowDownloads: true,
      );
      final clearedTag = filters.copyWith(clearTag: true);

      expect(filters.hasAny, isTrue);
      expect(clearedTag.tag, isNull);
      expect(clearedTag.allowDownloads, isTrue);
      expect(filters.cleared().hasAny, isFalse);
    });

    test('filter copyWith also exercises non-clearing replacement paths', () {
      const track = TrackSearchFilters(tag: 'rock');
      const collection = CollectionSearchFilters(type: CollectionFilterType.album);
      const people = PeopleSearchFilters(location: 'Cairo');

      expect(track.copyWith().tag, 'rock');
      expect(track.copyWith(tag: 'pop').tag, 'pop');
      expect(collection.copyWith().type, CollectionFilterType.album);
      expect(collection.copyWith(type: CollectionFilterType.playlist).type, CollectionFilterType.playlist);
      expect(people.copyWith().location, 'Cairo');
      expect(people.copyWith(location: 'Giza').location, 'Giza');
    });

    test('CollectionSearchFilters and PeopleSearchFilters support clearing and defaults', () {
      const collections = CollectionSearchFilters(
        type: CollectionFilterType.album,
        tag: 'party',
      );
      const people = PeopleSearchFilters(
        location: 'Cairo',
        minFollowers: 500,
        verifiedOnly: true,
        sort: PeopleSort.followers,
      );

      expect(collections.hasAny, isTrue);
      expect(collections.copyWith(clearType: true).type, isNull);
      expect(collections.cleared().hasAny, isFalse);

      expect(people.hasAny, isTrue);
      expect(people.copyWith(clearLocation: true).location, isNull);
      expect(people.cleared().hasAny, isFalse);
      expect(people.cleared().sort, PeopleSort.relevance);
    });
  });

  group('copyWith entities and states', () {
    test('TrackInteractionEntity and TrackPreviewEntity copyWith preserve unspecified fields', () {
      final updatedInteraction = interaction.copyWith(isReposted: true);
      final updatedPreview = preview.copyWith(title: 'Updated', duration: 200);

      expect(updatedInteraction.isLiked, isTrue);
      expect(updatedInteraction.isReposted, isTrue);
      expect(updatedPreview.title, 'Updated');
      expect(updatedPreview.duration, 200);
      expect(updatedPreview.artistName, 'Artist');
    });

    test('FeedItemEntity, CollectionEntity, and DiscoveryItemEntity copyWith update selected fields', () {
      final collection = CollectionEntity(
        id: 'collection-1',
        type: CollectionType.playlist,
        title: 'Playlist',
        creatorId: 'creator-1',
        creatorName: 'Curator',
        trackCount: 5,
        duration: 1000,
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final discovery = DiscoveryItemEntity(
        itemType: ResourceType.collection,
        collection: collection,
      );
      final updatedFeed = feedItem.copyWith(timeAgo: '3h');
      final updatedCollection = collection.copyWith(title: 'Updated Playlist');
      final updatedDiscovery = discovery.copyWith(
        itemType: ResourceType.user,
        user: UserPreviewEntity(
          id: 'user-1',
          username: 'Artist',
          followersCount: 100,
          verified: true,
          isFollowing: false,
        ),
      );

      expect(updatedFeed.timeAgo, '3h');
      expect(updatedFeed.track.title, 'Track');
      expect(updatedCollection.title, 'Updated Playlist');
      expect(updatedCollection.creatorName, 'Curator');
      expect(updatedDiscovery.itemType, ResourceType.user);
      expect(updatedDiscovery.user?.username, 'Artist');
    });

    test('FeedState copyWith replaces values and explicitly clears errors', () {
      final state = FeedState(
        followingItems: [feedItem],
        discoverItems: [feedItem],
        isDiscoverLoading: false,
        isFollowingLoading: true,
        hasLoadedDiscover: true,
        hasLoadedFollowing: true,
        isPreviewing: true,
        discoverError: 'discover failed',
        followingError: 'following failed',
      );

      final updated = state.copyWith(
        isPreviewing: false,
        discoverError: null,
        followingError: 'still failing',
      );

      expect(updated.followingItems, [feedItem]);
      expect(updated.isPreviewing, isFalse);
      expect(updated.discoverError, isNull);
      expect(updated.followingError, 'still failing');
    });

    test('TrendingState and SearchState copyWith respect clear flags', () {
      final trending = const TrendingState(error: 'old').copyWith(error: null);
      final search = const SearchState(error: 'old').copyWith(clearError: true);

      expect(trending.error, isNull);
      expect(search.error, isNull);
    });
  });
}
