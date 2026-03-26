class TrackArtistSummaryDto {
  const TrackArtistSummaryDto({
    required this.id,
    required this.name,
    required this.tier,
  });

  final String id;
  final String name;
  final String tier;

  factory TrackArtistSummaryDto.fromJson(Map<String, dynamic> json) {
    return TrackArtistSummaryDto(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      tier: (json['tier'] ?? 'free') as String,
    );
  }
}
