/// Raw JSON shape for each item in paginated list responses:
///   GET /collections/me
///   GET /users/:username/collections|albums|playlists
class PlaylistSummaryDto {
  final String id;
  final String title;
  final String? description;
  final String type;
  final String privacy;
  final String? coverUrl;
  final int trackCount;
  final int likeCount;
  final String createdAt;
  final String updatedAt;

  const PlaylistSummaryDto({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.privacy,
    this.coverUrl,
    required this.trackCount,
    required this.likeCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlaylistSummaryDto.fromJson(Map<String, dynamic> json) =>
      PlaylistSummaryDto(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        type: json['type'] as String,
        privacy: json['privacy'] as String,
        coverUrl: json['coverUrl'] as String?,
        trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
}
