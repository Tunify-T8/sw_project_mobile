import '../../domain/entities/search_all_result_entity.dart';
import '../../domain/entities/album_result_entity.dart';
import '../../domain/entities/genre_detail_entity.dart';
import '../../domain/entities/search_genre_entity.dart';
import '../../domain/entities/playlist_result_entity.dart';
import '../../domain/entities/profile_result_entity.dart';
import '../../domain/entities/track_result_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../services/mock_search_service.dart';

class MockSearchRepositoryImpl implements SearchRepository {
  MockSearchRepositoryImpl(this._service);

  final MockSearchService _service;

  @override
  Future<SearchAllResultEntity> searchAll(String query) =>
      _service.searchAll(query);

  @override
  Future<List<TrackResultEntity>> searchTracks(
    String query, {
    int page = 1,
    int limit = 20,
  }) => _service.searchTracks(query, page: page, limit: limit);

  @override
  Future<List<ProfileResultEntity>> searchProfiles(
    String query, {
    int page = 1,
    int limit = 20,
  }) => _service.searchProfiles(query, page: page, limit: limit);

  @override
  Future<List<PlaylistResultEntity>> searchPlaylists(
    String query, {
    int page = 1,
    int limit = 20,
  }) => _service.searchPlaylists(query, page: page, limit: limit);

  @override
  Future<List<AlbumResultEntity>> searchAlbums(
    String query, {
    int page = 1,
    int limit = 20,
  }) => _service.searchAlbums(query, page: page, limit: limit);

  @override
  Future<List<SearchGenreEntity>> getGenres() => _service.getGenres();

  @override
  Future<GenreDetailEntity> getGenreDetail(String genreId) =>
      _service.getGenreDetail(genreId);
}
