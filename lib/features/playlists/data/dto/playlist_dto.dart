/// Raw JSON shape returned by:
///   POST /collections (201)
///   GET  /collections/:id (200)
///   GET  /collections/token/:token (200)
///   PUT  /collections/:id (200)
class PlaylistDto {
  final String id;
  final String title;
  final String? description;
  final String type;
  final String privacy;
  final String? secretToken;
  final String? coverUrl;
  final int trackCount;
  final int likeCount;
  final PlaylistOwnerDto? owner;
  final String createdAt;
  final String updatedAt;

  const PlaylistDto({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.privacy,
    this.secretToken,
    this.coverUrl,
    required this.trackCount,
    required this.likeCount,
    this.owner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlaylistDto.fromJson(Map<String, dynamic> json) => PlaylistDto(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    type: json['type'] as String,
    privacy: json['privacy'] as String,
    secretToken: json['secretToken'] as String?,
    coverUrl: json['coverUrl'] as String?,
    trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
    likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
    owner: json['owner'] != null
        ? PlaylistOwnerDto.fromJson(json['owner'] as Map<String, dynamic>)
        : null,
    createdAt: json['createdAt'] as String,
    updatedAt: json['updatedAt'] as String,
  );
}

/// Embedded owner object inside [PlaylistDto].
class PlaylistOwnerDto {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  const PlaylistOwnerDto({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  factory PlaylistOwnerDto.fromJson(Map<String, dynamic> json) =>
      PlaylistOwnerDto(
        id: json['id'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );
}
