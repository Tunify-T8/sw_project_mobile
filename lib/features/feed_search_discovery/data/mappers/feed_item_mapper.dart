import 'track_preview_mapper.dart';
import 'user_preview_mapper.dart';
import '../../domain/entities/feed_item_entity.dart';
import '../dto/feed_item_dto.dart';

extension FeedItemMapper on FeedItemDto {
  FeedItemEntity toEntity() {
    return FeedItemEntity(
      source: source,
      timeAgo: timeAgo,
      track: track.toEntity(),
      actor: actor.toEntity(),
    );
  }
}