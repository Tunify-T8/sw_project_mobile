class SuggestedArtistDto {
  final String userId;
  final String name;
  final int followersCount;
  final int tracksCount;
  final List<String> genreTags;

  SuggestedArtistDto({
    required this.userId,
    required this.name,
    required this.followersCount,
    required this.tracksCount,
    required this.genreTags,
  });

  factory SuggestedArtistDto.fromJson(Map<String, dynamic> json) {
    return SuggestedArtistDto(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      followersCount: json['followersCount'] ?? 0,
      tracksCount: json['tracksCount'] ?? 0,
      genreTags: List<String>.from(json['genreTags'] ?? []),
    );
  }
}

class PaginatedSuggestedArtistsResponseDto {
  final List<SuggestedArtistDto> items;
  final int page;
  final int limit;
  final int total;

  PaginatedSuggestedArtistsResponseDto({required this.items, required this.page, required this.limit, required this.total});

  factory PaginatedSuggestedArtistsResponseDto.fromJson(Map<String, dynamic> json) {
    return PaginatedSuggestedArtistsResponseDto(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => SuggestedArtistDto.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}