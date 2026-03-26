import 'collection_dto.dart';

class CollectionSearchResponseDto {
  final List<CollectionDto> items;
  final int page;
  final int limit;
  final int total;

  CollectionSearchResponseDto({required this.items, required this.page, required this.limit, required this.total});

  factory CollectionSearchResponseDto.fromJson(Map<String, dynamic> json) {
    return CollectionSearchResponseDto(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CollectionDto.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}