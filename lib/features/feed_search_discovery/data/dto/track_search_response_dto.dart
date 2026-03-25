import 'track_preview_dto.dart';

class TrackSearchResponseDto {
  final List<TrackPreviewDto> items;
  final int page;
  final int limit;
  final int total;

  TrackSearchResponseDto({required this.items, required this.page, required this.limit, required this.total});

  factory TrackSearchResponseDto.fromJson(Map<String, dynamic> json) {
    return TrackSearchResponseDto(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => TrackPreviewDto.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}