/// Raw JSON shape for each item in GET /collections/:id/tracks.
///
/// The backend returns a nested `track` object; this DTO flattens it
/// into a single structure to keep the mapper simple.
class PlaylistTrackDto {
  final int position;
  final String addedAt;

  // Flattened from json['track']
  final String trackId;
  final String title;
  final int durationSeconds;
  final String? coverUrl;
  final String? genreId;
  final bool isPublic;
  final int playCount;

  // Flattened from json['track']['user']
  final String ownerId;
  final String ownerUsername;
  final String? ownerDisplayName;
  final String? ownerAvatarUrl;

  const PlaylistTrackDto({
    required this.position,
    required this.addedAt,
    required this.trackId,
    required this.title,
    required this.durationSeconds,
    this.coverUrl,
    this.genreId,
    required this.isPublic,
    required this.playCount,
    required this.ownerId,
    required this.ownerUsername,
    this.ownerDisplayName,
    this.ownerAvatarUrl,
  });

  factory PlaylistTrackDto.fromJson(Map<String, dynamic> json) {
    final track = json['track'] as Map<String, dynamic>;
    final user = track['user'] as Map<String, dynamic>;
    return PlaylistTrackDto(
      position: (json['position'] as num).toInt(),
      addedAt: json['addedAt'] as String,
      trackId: track['id'] as String,
      title: track['title'] as String,
      durationSeconds: (track['durationSeconds'] as num).toInt(),
      coverUrl: track['coverUrl'] as String?,
      genreId: track['genreId'] as String?,
      isPublic: track['isPublic'] as bool,
      playCount: (track['playCount'] as num?)?.toInt() ?? 0,
      ownerId: user['id'] as String,
      ownerUsername: user['username'] as String,
      ownerDisplayName: user['displayName'] as String?,
      ownerAvatarUrl: user['avatarUrl'] as String?,
    );
  }
}
