import '../../domain/entities/resource_type.dart';
import 'track_preview_dto.dart';
import 'collection_dto.dart';
import 'user_preview_dto.dart';

class DiscoveryItemDto {
  final ResourceType itemType;
  final TrackPreviewDto? track;
  final CollectionDto? collection;
  final UserPreviewDto? user;

  DiscoveryItemDto({required this.itemType, this.track, this.collection, this.user});

  factory DiscoveryItemDto.fromJson(Map<String, dynamic> json) {
    final type = ResourceType.values.byName(json['itemType']);
    return DiscoveryItemDto(
      itemType: type,
      track: type == ResourceType.track ? TrackPreviewDto.fromJson(json['resource']) : null,
      collection: type == ResourceType.collection ? CollectionDto.fromJson(json['resource']) : null,
      user: type == ResourceType.user ? UserPreviewDto.fromJson(json['resource']) : null,
    );
  }
}

class PaginatedDiscoveryResponseDto {
  final List<DiscoveryItemDto> items;
  final int page;
  final int limit;
  final int total;

  PaginatedDiscoveryResponseDto({required this.items, required this.page, required this.limit, required this.total});

  factory PaginatedDiscoveryResponseDto.fromJson(Map<String, dynamic> json) {
    return PaginatedDiscoveryResponseDto(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => DiscoveryItemDto.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}