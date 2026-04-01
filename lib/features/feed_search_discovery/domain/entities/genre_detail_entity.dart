import 'track_result_entity.dart';
import 'playlist_result_entity.dart';
import 'profile_result_entity.dart';
import 'album_result_entity.dart';

// ─── Genre detail aggregate result ───────────────────────────────────────────
// Used when user taps a genre from the idle grid.
// The genre detail screen has tabs: All | Trending | Playlists | Albums
class GenreDetailEntity {
  final String genreId;
  final String genreLabel;
  final String? artworkUrl;

  /// "Trending" section — top tracks in this genre.
  final List<TrackResultEntity> trendingTracks;

  /// "Introducing" section — new tracks in this genre.
  final List<TrackResultEntity> introducingTracks;

  /// Playlists in this genre.
  final List<PlaylistResultEntity> playlists;

  /// Notable profiles/artists in this genre.
  final List<ProfileResultEntity> profiles;

  /// Albums in this genre.
  final List<AlbumResultEntity> albums;

  const GenreDetailEntity({
    required this.genreId,
    required this.genreLabel,
    this.artworkUrl,
    this.trendingTracks = const [],
    this.introducingTracks = const [],
    this.playlists = const [],
    this.profiles = const [],
    this.albums = const [],
  });
}
