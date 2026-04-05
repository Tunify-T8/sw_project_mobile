class TrendingItemDto {
  final String id;
  final String name;
  final String artist;
  final String? coverUrl;
  final String type; // "track" | "album" | "playlist"
  final int score;

  const TrendingItemDto({
    required this.id,
    required this.name,
    required this.artist,
    this.coverUrl,
    required this.type,
    required this.score,
  });

  factory TrendingItemDto.fromJson(Map<String, dynamic> json) {
    return TrendingItemDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      coverUrl: json['coverUrl']?.toString(),
      type: json['type']?.toString() ?? 'track',
      score: json['score'] as int? ?? 0,
    );
  }
}

class PaginatedTrendingResponseDto {
  final List<TrendingItemDto> items;
  final String type;
  final String period;

  const PaginatedTrendingResponseDto({
    required this.items,
    required this.type,
    required this.period,
  });

  factory PaginatedTrendingResponseDto.fromJson(Map<String, dynamic> json) {
    return PaginatedTrendingResponseDto(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => TrendingItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: json['type']?.toString() ?? 'track',
      period: json['period']?.toString() ?? 'week',
    );
  }
}
