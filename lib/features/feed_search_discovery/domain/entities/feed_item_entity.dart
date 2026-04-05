import 'feed_item_source.dart';
import 'track_preview_entity.dart';
import 'feed_actor_entity.dart';

class FeedItemEntity {
  final FeedItemSource source;
  final String timeAgo;
  final TrackPreviewEntity track;
  final FeedActorEntity actor;

  FeedItemEntity({
    required this.source,
    required this.timeAgo,
    required this.track,
    required this.actor,
  });

  FeedItemEntity copyWith({
    FeedItemSource? source,
    String? postedAt,
    String? timeAgo,
    TrackPreviewEntity? track,
    FeedActorEntity? actor,
  }) {
    return FeedItemEntity(
      source: source ?? this.source,
      timeAgo: timeAgo ?? this.timeAgo,
      track: track ?? this.track,
      actor: actor ?? this.actor,
    );
  }
}
