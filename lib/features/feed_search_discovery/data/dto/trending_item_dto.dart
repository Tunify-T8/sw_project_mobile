import '../../domain/entities/resource_type.dart';
import 'track_preview_dto.dart';
import 'collection_dto.dart';
import 'user_preview_dto.dart';

class TrendingItemDto {
  final ResourceType itemType;
  final TrackPreviewDto? track;
  final CollectionDto? collection;
  final UserPreviewDto? user;

  TrendingItemDto({required this.itemType, this.track, this.collection, this.user});

  factory TrendingItemDto.fromJson(Map<String, dynamic> json) {
    final type = ResourceType.values.byName(json['itemType']);
    return TrendingItemDto(
      itemType: type,
      track: type == ResourceType.track ? TrackPreviewDto.fromJson(json['resource']) : null,
      collection: type == ResourceType.collection ? CollectionDto.fromJson(json['resource']) : null,
      user: type == ResourceType.user ? UserPreviewDto.fromJson(json['resource']) : null,
    );
  }
}

class PaginatedTrendingResponseDto {
  final List<TrendingItemDto> items;
  final int page;
  final int limit;
  final int total;

  PaginatedTrendingResponseDto({required this.items, required this.page, required this.limit, required this.total});

  factory PaginatedTrendingResponseDto.fromJson(Map<String, dynamic> json) {
    return PaginatedTrendingResponseDto(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => TrendingItemDto.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}