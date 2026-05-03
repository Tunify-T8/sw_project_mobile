import '../../domain/entities/feed_item_entity.dart';
import '../../domain/entities/feed_item_source.dart';
import '../../domain/entities/track_preview_entity.dart';
import '../../domain/entities/track_interaction_entity.dart';
import '../dto/feed_item_dto.dart';
import '../../domain/entities/feed_actor_entity.dart';

extension FeedItemMapper on FeedItemDto {
  String _calculateTimeAgo(String? createdAt) {
    if (createdAt == null) return ' ';
    final date = DateTime.parse(createdAt);
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null) return ' ';
    final DateTime date = DateTime.parse(createdAt).toLocal();
    final String hour = date.hour.toString();
    final String minute = date.minute.toString();
    return '$hour:$minute';
  }

  FeedItemSource? _mapSource(final action) {
    if (action == null || action.action.isEmpty) return null;

    try {
      return FeedItemSource.values.byName(action.action);
    } catch (_) {
      return null;
    }
  }

  FeedActorEntity? _mapActor(final action) {
    if (action == null) return null;

    return FeedActorEntity(
      id: action.actorId,
      username: action.username,
      avatarUrl: action.avatarUrl,
    );
  }

  FeedItemEntity toEntity() {
    return FeedItemEntity(
      source: _mapSource(action),
      timeAgo: _calculateTimeAgo(action?.date),
      discoverReason: reason,
      track: TrackPreviewEntity(
        trackId: trackId,
        title: title,
        artistId: artistId,
        artistName: artist,
        artistAvatar: artistAvatarUrl,
        isArtistCertified: artistIsCertified,
        isFollowingArtist: isFollowingArtist,
        coverUrl: coverUrl,
        duration: durationInSeconds,
        listensCount: numberOfListens,
        likesCount: numberOfLikes,
        commentsCount: numberOfComments,
        repostsCount: numberOfReposts,
        createdAt: _formatTime(action?.date),
        interaction: TrackInteractionEntity(
          isLiked: isLiked,
          isReposted: isReposted,
        ),
      ),
      actor: _mapActor(action)
    );
  }
}
