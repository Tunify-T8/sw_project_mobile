import '../../domain/entities/feed_item_source.dart';
import '../../domain/entities/feed_item_type.dart';
import 'track_preview_dto.dart';

class FeedItemDto {
  final FeedItemType type;
  final FeedItemSource source;
  final String postedAt;
  final TrackPreviewDto track;

  FeedItemDto({
    required this.type,
    required this.source,
    required this.postedAt,
    required this.track,
  });

  factory FeedItemDto.fromJson(Map<String, dynamic> json) {
    return FeedItemDto(
      type: FeedItemType.values.byName(json['type']),
      source: FeedItemSource.values.byName(json['source']),
      postedAt: json['postedAt']?.toString() ?? '',
      track: TrackPreviewDto.fromJson(json['track']),
    );
  }
}

class PaginatedFeedResponseDto {
  final List<FeedItemDto> items;
  final int page;
  final int limit;
  final int total;

  PaginatedFeedResponseDto({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory PaginatedFeedResponseDto.fromJson(Map<String, dynamic> json) {
    return PaginatedFeedResponseDto(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => FeedItemDto.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}
