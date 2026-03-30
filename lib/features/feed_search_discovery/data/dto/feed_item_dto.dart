import '../../domain/entities/feed_item_source.dart';
import 'track_preview_dto.dart';
import 'user_preview_dto.dart';

class FeedItemDto {
  final FeedItemSource source;
  final String postedAt;
  final String timeAgo;
  final TrackPreviewDto track;
  final UserPreviewDto actor;

  FeedItemDto({
    required this.source,
    required this.postedAt,
    required this.timeAgo,
    required this.track,
    required this.actor,
  });

  factory FeedItemDto.fromJson(Map<String, dynamic> json) {
    return FeedItemDto(
      source: FeedItemSource.values.byName(json['source']),
      postedAt: json['postedAt']?.toString() ?? '',
      timeAgo: json['timeAgo']?.toString() ?? '',
      track: TrackPreviewDto.fromJson(json['track']),
      actor: UserPreviewDto.fromJson(json['actor']),
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