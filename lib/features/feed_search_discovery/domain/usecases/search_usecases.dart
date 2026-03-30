// lib/features/feed_search_discovery/domain/usecases/search_usecases.dart
//
// One use case per user-facing action. Each is a thin callable class that
// delegates to SearchRepository. This keeps providers and UI free of
// repository imports and makes unit testing trivial.

import '../entities/search_all_result_entity.dart';
import '../entities/album_result_entity.dart';
import '../entities/genre_detail_entity.dart';
import '../entities/search_genre_entity.dart';
import '../entities/playlist_result_entity.dart';
import '../entities/profile_result_entity.dart';
import '../entities/track_result_entity.dart';
import '../entities/search_filters_entity.dart';
import '../repositories/search_repository.dart';

// ─── Global search (All tab) ───────────────────────────────────────────────

class SearchAllUseCase {
  const SearchAllUseCase(this._repository);
  final SearchRepository _repository;

  Future<SearchAllResultEntity> call(String query) =>
      _repository.searchAll(query);
}

// ─── Track search ──────────────────────────────────────────────────────────

class SearchTracksUseCase {
  const SearchTracksUseCase(this._repository);
  final SearchRepository _repository;

  Future<List<TrackResultEntity>> call(
    String query, {
    int page = 1,
    int limit = 20,
    TrackSearchFilters filters = const TrackSearchFilters(),
  }) => _repository.searchTracks(
    query,
    page: page,
    limit: limit,
    filters: filters,
  );
}

// ─── Profile search ────────────────────────────────────────────────────────

class SearchProfilesUseCase {
  const SearchProfilesUseCase(this._repository);
  final SearchRepository _repository;

  Future<List<ProfileResultEntity>> call(
    String query, {
    int page = 1,
    int limit = 20,
    PeopleSearchFilters filters = const PeopleSearchFilters(),
  }) => _repository.searchProfiles(
    query,
    page: page,
    limit: limit,
    filters: filters,
  );
}

// ─── Playlist search ───────────────────────────────────────────────────────

class SearchPlaylistsUseCase {
  const SearchPlaylistsUseCase(this._repository);
  final SearchRepository _repository;

  Future<List<PlaylistResultEntity>> call(
    String query, {
    int page = 1,
    int limit = 20,
    CollectionSearchFilters filters = const CollectionSearchFilters(),
  }) => _repository.searchPlaylists(
    query,
    page: page,
    limit: limit,
    filters: filters,
  );
}

// ─── Album search ──────────────────────────────────────────────────────────

class SearchAlbumsUseCase {
  const SearchAlbumsUseCase(this._repository);
  final SearchRepository _repository;

  Future<List<AlbumResultEntity>> call(
    String query, {
    int page = 1,
    int limit = 20,
    CollectionSearchFilters filters = const CollectionSearchFilters(),
  }) => _repository.searchAlbums(
    query,
    page: page,
    limit: limit,
    filters: filters,
  );
}

// ─── Get genres ────────────────────────────────────────────────────────────

class GetGenresUseCase {
  const GetGenresUseCase(this._repository);
  final SearchRepository _repository;

  Future<List<SearchGenreEntity>> call() => _repository.getGenres();
}

// ─── Get genre detail ──────────────────────────────────────────────────────

class GetGenreDetailUseCase {
  const GetGenreDetailUseCase(this._repository);
  final SearchRepository _repository;

  Future<GenreDetailEntity> call(String genreId) =>
      _repository.getGenreDetail(genreId);
}
