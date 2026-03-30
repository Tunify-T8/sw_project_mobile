import 'feed_item_source.dart';
import 'track_preview_entity.dart';
import 'user_preview_entity.dart';

class FeedItemEntity {
  final FeedItemSource source;
  final String timeAgo;
  final TrackPreviewEntity track;
  final UserPreviewEntity actor;

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
    UserPreviewEntity? actor,
  }) {
    return FeedItemEntity(
      source: source ?? this.source,
      timeAgo: timeAgo ?? this.timeAgo,
      track: track ?? this.track,
      actor: actor ?? this.actor,
    );
  }
}