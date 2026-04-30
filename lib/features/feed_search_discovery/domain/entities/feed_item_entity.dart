import 'feed_item_source.dart';
import 'track_preview_entity.dart';
import 'feed_actor_entity.dart';

class FeedItemEntity {
  final FeedItemSource? source;
  final String timeAgo;
  final TrackPreviewEntity track;
  final FeedActorEntity? actor;
  final String? discoverReason;

  FeedItemEntity({
    this.source,
    required this.timeAgo,
    required this.track,
    this.actor,
    this.discoverReason
  });

  FeedItemEntity copyWith({
    FeedItemSource? source,
    String? postedAt,
    String? timeAgo,
    TrackPreviewEntity? track,
    FeedActorEntity? actor,
    String? discoverReason
  }) {
    return FeedItemEntity(
      source: source ?? this.source,
      timeAgo: timeAgo ?? this.timeAgo,
      track: track ?? this.track,
      actor: actor ?? this.actor,
      discoverReason: discoverReason ?? this.discoverReason
    );
  }
}
