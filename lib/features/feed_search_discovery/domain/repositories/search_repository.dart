import '../entities/search_all_result_entity.dart';
import '../entities/album_result_entity.dart';
import '../entities/genre_detail_entity.dart';
import '../entities/search_genre_entity.dart';
import '../entities/playlist_result_entity.dart';
import '../entities/profile_result_entity.dart';
import '../entities/track_result_entity.dart';
import '../entities/search_filters_entity.dart';

abstract class SearchRepository {
  /// Global search — powers the "All" tab aggregate view.
  Future<SearchAllResultEntity> searchAll(String query);

  /// Track search with optional filters.
  Future<List<TrackResultEntity>> searchTracks(
    String query, {
    int page = 1,
    int limit = 20,
    TrackSearchFilters filters = const TrackSearchFilters(),
  });

  /// Profile/people search with optional filters.
  Future<List<ProfileResultEntity>> searchProfiles(
    String query, {
    int page = 1,
    int limit = 20,
    PeopleSearchFilters filters = const PeopleSearchFilters(),
  });

  /// Playlist search with optional filters.
  Future<List<PlaylistResultEntity>> searchPlaylists(
    String query, {
    int page = 1,
    int limit = 20,
    CollectionSearchFilters filters = const CollectionSearchFilters(),
  });

  /// Album search with optional filters.
  Future<List<AlbumResultEntity>> searchAlbums(
    String query, {
    int page = 1,
    int limit = 20,
    CollectionSearchFilters filters = const CollectionSearchFilters(),
  });

  /// Genre grid for the idle screen.
  Future<List<SearchGenreEntity>> getGenres();

  /// Genre detail for the genre selected screen.
  Future<GenreDetailEntity> getGenreDetail(String genreId);
}
