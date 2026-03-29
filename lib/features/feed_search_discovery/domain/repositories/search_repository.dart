import '../entities/search_all_result_entity.dart';
import '../entities/album_result_entity.dart';
import '../entities/genre_detail_entity.dart';
import '../entities/search_genre_entity.dart';
import '../entities/playlist_result_entity.dart';
import '../entities/profile_result_entity.dart';
import '../entities/track_result_entity.dart';

abstract class SearchRepository {
  /// Global search — powers the "All" tab aggregate view.
  /// [query] is the raw text from the search bar.
  Future<SearchAllResultEntity> searchAll(String query);

  /// Tab-specific searches — each returns a paginated flat list.
  Future<List<TrackResultEntity>> searchTracks(
    String query, {
    int page = 1,
    int limit = 20,
  });

  Future<List<ProfileResultEntity>> searchProfiles(
    String query, {
    int page = 1,
    int limit = 20,
  });

  Future<List<PlaylistResultEntity>> searchPlaylists(
    String query, {
    int page = 1,
    int limit = 20,
  });

  Future<List<AlbumResultEntity>> searchAlbums(
    String query, {
    int page = 1,
    int limit = 20,
  });

  /// Genre grid — returns the list of genres shown on the idle screen.
  Future<List<SearchGenreEntity>> getGenres();

  /// Genre detail — returns trending/playlists/profiles for a given genre.
  Future<GenreDetailEntity> getGenreDetail(String genreId);
}
