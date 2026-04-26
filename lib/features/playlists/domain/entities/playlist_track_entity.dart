/// A track as it appears inside a collection.
/// Returned by GET /collections/:id/tracks.
///
/// [position] is 1-based as the backend defines it.
class PlaylistTrackEntity {
  final int position;
  final DateTime addedAt;

  // Flattened track fields from the nested `track` object.
  final String trackId;
  final String title;
  final int durationSeconds;
  final String? coverUrl;
  final String? genreId;
  final bool isPublic;

  /// Total play count for this track.
  final int playCount;

  // Owner of the track (not the playlist owner).
  final String ownerId;
  final String ownerUsername;
  final String? ownerDisplayName;
  final String? ownerAvatarUrl;

  const PlaylistTrackEntity({
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
}
