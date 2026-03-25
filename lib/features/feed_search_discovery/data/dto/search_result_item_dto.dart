// search_result_item_dto.dart
import '../../domain/entities/resource_type.dart';
import 'track_preview_dto.dart';
import 'collection_dto.dart';
import 'user_preview_dto.dart';

class SearchResultItemDto {
  final ResourceType itemType;
  final TrackPreviewDto? track;
  final CollectionDto? collection;
  final UserPreviewDto? user;

  SearchResultItemDto({required this.itemType, this.track, this.collection, this.user});

  factory SearchResultItemDto.fromJson(Map<String, dynamic> json) {
    final type = ResourceType.values.byName(json['itemType']);
    return SearchResultItemDto(
      itemType: type,
      track: type == ResourceType.track ? TrackPreviewDto.fromJson(json['resource']) : null,
      collection: type == ResourceType.collection ? CollectionDto.fromJson(json['resource']) : null,
      user: type == ResourceType.user ? UserPreviewDto.fromJson(json['resource']) : null,
    );
  }
}

class PaginatedSearchResponseDto {
  final List<SearchResultItemDto> items;
  final int page;
  final int limit;
  final int total;

  PaginatedSearchResponseDto({required this.items, required this.page, required this.limit, required this.total});

  factory PaginatedSearchResponseDto.fromJson(Map<String, dynamic> json) {
    return PaginatedSearchResponseDto(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => SearchResultItemDto.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}