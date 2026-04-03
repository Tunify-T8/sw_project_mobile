import '../../domain/entities/feed_actor_entity.dart';
import '../../domain/entities/feed_item_entity.dart';
import '../../domain/entities/feed_item_source.dart';
import '../../domain/entities/track_interaction_entity.dart';
import '../../domain/entities/track_preview_entity.dart';

class MockFeedService {
  Future<List<FeedItemEntity>> getFollowingFeed() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      FeedItemEntity(
        source: FeedItemSource.post,
        timeAgo: '2h',
        actor: FeedActorEntity(
          id: 'u1',
          username: 'Drake',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
        ),
        track: TrackPreviewEntity(
          trackId: 't1',
          title: 'Midnight Drive',
          artistId: 'a1',
          artistName: 'Drake',
          artistAvatar: 'https://i.pravatar.cc/150?img=1',
          artistVerified: true,
          isFollowingArtist: true,
          coverUrl: 'https://picsum.photos/400/400?random=1',
          duration: 215,
          listensCount: 12400,
          likesCount: 320,
          repostsCount: 28,
          commentsCount: 45,
          createdAt: '5:20',
          interaction: TrackInteractionEntity(
            isLiked: true,
            isReposted: false,
          ),
        ),
      ),
      FeedItemEntity(
        source: FeedItemSource.repost,
        timeAgo: '4h',
        actor: FeedActorEntity(
          id: 'u2',
          username: 'Billie',
          avatarUrl: 'https://i.pravatar.cc/150?img=2',
        ),
        track: TrackPreviewEntity(
          trackId: 't2',
          title: 'Ocean Lights',
          artistId: 'a2',
          artistName: 'The Weeknd',
          artistAvatar: 'https://i.pravatar.cc/150?img=3',
          artistVerified: true,
          isFollowingArtist: false,
          coverUrl: 'https://picsum.photos/400/400?random=2',
          duration: 198,
          listensCount: 28600,
          likesCount: 510,
          repostsCount: 93,
          commentsCount: 80,
          createdAt: '4:10',
          interaction: TrackInteractionEntity(
            isLiked: false,
            isReposted: true,
          ),
        ),
      ),
    ];
  }

  Future<List<FeedItemEntity>> getDiscoverFeed() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      FeedItemEntity(
        source: FeedItemSource.becauseYouLiked,
        timeAgo: '2h',
        actor: FeedActorEntity(
          id: 'u1',
          username: 'Drake',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
        ),
        track: TrackPreviewEntity(
          trackId: 't1',
          title: 'Midnight Drive',
          artistId: 'a1',
          artistName: 'Drake',
          artistAvatar: 'https://i.pravatar.cc/150?img=1',
          artistVerified: true,
          isFollowingArtist: false,
          coverUrl: 'https://picsum.photos/400/400?random=1',
          duration: 215,
          listensCount: 12400,
          likesCount: 320,
          repostsCount: 28,
          commentsCount: 45,
          createdAt: '5:20',
          interaction: TrackInteractionEntity(
            isLiked: true,
            isReposted: false,
          ),
        ),
      ),
      FeedItemEntity(
        source: FeedItemSource.becauseYouFollow,
        timeAgo: '4h',
        actor: FeedActorEntity(
          id: 'u2',
          username: 'Billie',
          avatarUrl: 'https://i.pravatar.cc/150?img=2',
        ),
        track: TrackPreviewEntity(
          trackId: 't2',
          title: 'Ocean Lights',
          artistId: 'a2',
          artistName: 'The Weeknd',
          artistAvatar: 'https://i.pravatar.cc/150?img=3',
          artistVerified: true,
          isFollowingArtist: true,
          coverUrl: 'https://picsum.photos/400/400?random=2',
          duration: 198,
          listensCount: 28600,
          likesCount: 510,
          repostsCount: 93,
          commentsCount: 80,
          createdAt: '4:10',
          interaction: TrackInteractionEntity(
            isLiked: false,
            isReposted: false,
          ),
        ),
      ),
      FeedItemEntity(
        source: FeedItemSource.newRelease,
        timeAgo: '1h',
        actor: FeedActorEntity(
          id: 'u3',
          username: 'Travis Scott',
          avatarUrl: 'https://i.pravatar.cc/150?img=4',
        ),
        track: TrackPreviewEntity(
          trackId: 't3',
          title: 'Astro Vibes',
          artistId: 'a3',
          artistName: 'Travis Scott',
          artistAvatar: 'https://i.pravatar.cc/150?img=4',
          artistVerified: true,
          isFollowingArtist: false,
          coverUrl: 'https://picsum.photos/400/400?random=3',
          duration: 230,
          listensCount: 54300,
          likesCount: 900,
          repostsCount: 140,
          commentsCount: 120,
          createdAt: '1:00',
          interaction: TrackInteractionEntity(
            isLiked: false,
            isReposted: false,
          ),
        ),
      ),
    ];
  }
}