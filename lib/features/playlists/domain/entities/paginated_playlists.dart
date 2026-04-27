import 'playlist_summary_entity.dart';
import 'playlist_track_entity.dart';

/// Paginated wrapper for collection list responses.
class PaginatedPlaylists {
  final List<PlaylistSummaryEntity> items;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  const PaginatedPlaylists({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });
}

/// Paginated wrapper for GET /collections/:id/tracks.
class PaginatedPlaylistTracks {
  final List<PlaylistTrackEntity> items;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  const PaginatedPlaylistTracks({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });
}
