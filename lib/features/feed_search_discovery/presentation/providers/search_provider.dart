// lib/features/feed_search_discovery/presentation/providers/search_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/mock_search_repository_impl.dart';
import '../../data/services/mock_search_service.dart';
import '../../domain/entities/search_all_result_entity.dart';
import '../../domain/entities/album_result_entity.dart';
import '../../domain/entities/genre_detail_entity.dart';
// SearchTab lives in search_genre_entity.dart — import only from there.
// Do NOT also import search_tab.dart or the name becomes ambiguous.
import '../../domain/entities/search_genre_entity.dart';
import '../../domain/entities/playlist_result_entity.dart';
import '../../domain/entities/profile_result_entity.dart';
import '../../domain/entities/track_result_entity.dart';
import '../../domain/entities/search_filters_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/search_usecases.dart';

// ─── Repository provider ──────────────────────────────────────────────────────

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return MockSearchRepositoryImpl(MockSearchService());
  // Swap when backend is ready:
  // return RealSearchRepositoryImpl(DiscoveryApi(ref.read(dioProvider)));
});

// ─── Use case providers ───────────────────────────────────────────────────────

final searchAllUseCaseProvider = Provider(
  (ref) => SearchAllUseCase(ref.read(searchRepositoryProvider)),
);
final searchTracksUseCaseProvider = Provider(
  (ref) => SearchTracksUseCase(ref.read(searchRepositoryProvider)),
);
final searchProfilesUseCaseProvider = Provider(
  (ref) => SearchProfilesUseCase(ref.read(searchRepositoryProvider)),
);
final searchPlaylistsUseCaseProvider = Provider(
  (ref) => SearchPlaylistsUseCase(ref.read(searchRepositoryProvider)),
);
final searchAlbumsUseCaseProvider = Provider(
  (ref) => SearchAlbumsUseCase(ref.read(searchRepositoryProvider)),
);
final getGenresUseCaseProvider = Provider(
  (ref) => GetGenresUseCase(ref.read(searchRepositoryProvider)),
);
final getGenreDetailUseCaseProvider = Provider(
  (ref) => GetGenreDetailUseCase(ref.read(searchRepositoryProvider)),
);

// ─── Screen mode ─────────────────────────────────────────────────────────────

enum SearchScreenMode { idle, typing, results }

// ─── Search state ─────────────────────────────────────────────────────────────

class SearchState {
  const SearchState({
    this.mode = SearchScreenMode.idle,
    this.query = '',
    this.activeTab = SearchTab.all,
    this.genres = const [],
    this.isLoadingGenres = false,
    this.allResult,
    this.tracks = const [],
    this.profiles = const [],
    this.playlists = const [],
    this.albums = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.page = 1,
    this.recentSearches = const [],
    this.trackFilters = const TrackSearchFilters(),
    this.collectionFilters = const CollectionSearchFilters(),
    this.peopleFilters = const PeopleSearchFilters(),
  });

  final SearchScreenMode mode;
  final String query;
  final SearchTab activeTab;
  final List<SearchGenreEntity> genres;
  final bool isLoadingGenres;
  final SearchAllResultEntity? allResult;
  final List<TrackResultEntity> tracks;
  final List<ProfileResultEntity> profiles;
  final List<PlaylistResultEntity> playlists;
  final List<AlbumResultEntity> albums;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final int page;
  final List<String> recentSearches;
  final TrackSearchFilters trackFilters;
  final CollectionSearchFilters collectionFilters;
  final PeopleSearchFilters peopleFilters;

  bool get hasResults {
    switch (activeTab) {
      case SearchTab.all:
        final r = allResult;
        if (r == null) return false;
        return r.topResult != null ||
            r.tracks.isNotEmpty ||
            r.playlists.isNotEmpty ||
            r.profiles.isNotEmpty;
      case SearchTab.tracks:
        return tracks.isNotEmpty;
      case SearchTab.profiles:
        return profiles.isNotEmpty;
      case SearchTab.playlists:
        return playlists.isNotEmpty;
      case SearchTab.albums:
        return albums.isNotEmpty;
    }
  }

  bool get activeTabHasFilters {
    switch (activeTab) {
      case SearchTab.tracks:
        return trackFilters.hasAny;
      case SearchTab.profiles:
        return peopleFilters.hasAny;
      case SearchTab.playlists:
      case SearchTab.albums:
        return collectionFilters.hasAny;
      case SearchTab.all:
        return false;
    }
  }

  SearchState copyWith({
    SearchScreenMode? mode,
    String? query,
    SearchTab? activeTab,
    List<SearchGenreEntity>? genres,
    bool? isLoadingGenres,
    SearchAllResultEntity? allResult,
    List<TrackResultEntity>? tracks,
    List<ProfileResultEntity>? profiles,
    List<PlaylistResultEntity>? playlists,
    List<AlbumResultEntity>? albums,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    bool? hasMore,
    int? page,
    List<String>? recentSearches,
    TrackSearchFilters? trackFilters,
    CollectionSearchFilters? collectionFilters,
    PeopleSearchFilters? peopleFilters,
  }) {
    return SearchState(
      mode: mode ?? this.mode,
      query: query ?? this.query,
      activeTab: activeTab ?? this.activeTab,
      genres: genres ?? this.genres,
      isLoadingGenres: isLoadingGenres ?? this.isLoadingGenres,
      allResult: allResult ?? this.allResult,
      tracks: tracks ?? this.tracks,
      profiles: profiles ?? this.profiles,
      playlists: playlists ?? this.playlists,
      albums: albums ?? this.albums,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      recentSearches: recentSearches ?? this.recentSearches,
      trackFilters: trackFilters ?? this.trackFilters,
      collectionFilters: collectionFilters ?? this.collectionFilters,
      peopleFilters: peopleFilters ?? this.peopleFilters,
    );
  }
}

// ─── Search notifier ──────────────────────────────────────────────────────────

class SearchNotifier extends Notifier<SearchState> {
  static const int _pageSize = 20;

  @override
  SearchState build() {
    Future.microtask(_loadGenres);
    return const SearchState();
  }

  Future<void> _loadGenres() async {
    state = state.copyWith(isLoadingGenres: true);
    try {
      final genres = await ref.read(getGenresUseCaseProvider).call();
      state = state.copyWith(isLoadingGenres: false, genres: genres);
    } catch (_) {
      state = state.copyWith(isLoadingGenres: false);
    }
  }

  void onSearchFocused() {
    if (state.mode == SearchScreenMode.idle) {
      state = state.copyWith(mode: SearchScreenMode.typing);
    }
  }

  void onQueryChanged(String query) {
    state = state.copyWith(query: query, mode: SearchScreenMode.typing);
  }

  Future<void> onQuerySubmitted(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final updated = [
      trimmed,
      ...state.recentSearches.where((s) => s != trimmed),
    ].take(5).toList();
    state = state.copyWith(
      query: trimmed,
      mode: SearchScreenMode.results,
      activeTab: SearchTab.all,
      isLoading: true,
      clearError: true,
      recentSearches: updated,
      allResult: null,
      tracks: [],
      profiles: [],
      playlists: [],
      albums: [],
      page: 1,
      hasMore: true,
    );
    await _loadActiveTab(trimmed);
  }

  void onSearchCleared() {
    state = state.copyWith(
      query: '',
      mode: SearchScreenMode.idle,
      clearError: true,
      allResult: null,
      tracks: [],
      profiles: [],
      playlists: [],
      albums: [],
    );
  }

  void onSearchDismissed() {
    state = state.copyWith(
      mode: SearchScreenMode.idle,
      query: '',
      clearError: true,
    );
  }

  Future<void> setActiveTab(SearchTab tab) async {
    if (state.activeTab == tab || state.query.trim().isEmpty) return;
    state = state.copyWith(
      activeTab: tab,
      isLoading: true,
      clearError: true,
      page: 1,
      hasMore: true,
    );
    await _loadActiveTab(state.query, tab: tab);
  }

  Future<void> applyTrackFilters(TrackSearchFilters filters) async {
    if (state.query.trim().isEmpty) return;
    state = state.copyWith(
      trackFilters: filters,
      tracks: [],
      page: 1,
      hasMore: true,
      isLoading: true,
    );
    await _loadActiveTab(state.query, tab: SearchTab.tracks);
  }

  Future<void> applyCollectionFilters(CollectionSearchFilters filters) async {
    if (state.query.trim().isEmpty) return;
    state = state.copyWith(
      collectionFilters: filters,
      playlists: [],
      albums: [],
      page: 1,
      hasMore: true,
      isLoading: true,
    );
    await _loadActiveTab(state.query, tab: state.activeTab);
  }

  Future<void> applyPeopleFilters(PeopleSearchFilters filters) async {
    if (state.query.trim().isEmpty) return;
    state = state.copyWith(
      peopleFilters: filters,
      profiles: [],
      page: 1,
      hasMore: true,
      isLoading: true,
    );
    await _loadActiveTab(state.query, tab: SearchTab.profiles);
  }

  Future<void> clearFiltersForActiveTab() async {
    switch (state.activeTab) {
      case SearchTab.tracks:
        await applyTrackFilters(const TrackSearchFilters());
        break;
      case SearchTab.profiles:
        await applyPeopleFilters(const PeopleSearchFilters());
        break;
      case SearchTab.playlists:
      case SearchTab.albums:
        await applyCollectionFilters(const CollectionSearchFilters());
        break;
      case SearchTab.all:
        break;
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    if (state.activeTab == SearchTab.all || state.query.trim().isEmpty) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.page + 1;
    try {
      switch (state.activeTab) {
        case SearchTab.tracks:
          final more = await ref
              .read(searchTracksUseCaseProvider)
              .call(
                state.query,
                page: nextPage,
                limit: _pageSize,
                filters: state.trackFilters,
              );
          state = state.copyWith(
            isLoadingMore: false,
            tracks: [...state.tracks, ...more],
            page: nextPage,
            hasMore: more.length >= _pageSize,
          );
          break;
        case SearchTab.profiles:
          final more = await ref
              .read(searchProfilesUseCaseProvider)
              .call(
                state.query,
                page: nextPage,
                limit: _pageSize,
                filters: state.peopleFilters,
              );
          state = state.copyWith(
            isLoadingMore: false,
            profiles: [...state.profiles, ...more],
            page: nextPage,
            hasMore: more.length >= _pageSize,
          );
          break;
        case SearchTab.playlists:
          final more = await ref
              .read(searchPlaylistsUseCaseProvider)
              .call(
                state.query,
                page: nextPage,
                limit: _pageSize,
                filters: state.collectionFilters,
              );
          state = state.copyWith(
            isLoadingMore: false,
            playlists: [...state.playlists, ...more],
            page: nextPage,
            hasMore: more.length >= _pageSize,
          );
          break;
        case SearchTab.albums:
          final more = await ref
              .read(searchAlbumsUseCaseProvider)
              .call(
                state.query,
                page: nextPage,
                limit: _pageSize,
                filters: state.collectionFilters,
              );
          state = state.copyWith(
            isLoadingMore: false,
            albums: [...state.albums, ...more],
            page: nextPage,
            hasMore: more.length >= _pageSize,
          );
          break;
        case SearchTab.all:
          state = state.copyWith(isLoadingMore: false);
          break;
      }
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void removeRecentSearch(String query) {
    state = state.copyWith(
      recentSearches: state.recentSearches.where((s) => s != query).toList(),
    );
  }

  void clearRecentSearches() => state = state.copyWith(recentSearches: []);

  Future<void> onRecentSearchTapped(String query) => onQuerySubmitted(query);

  Future<void> _loadActiveTab(String query, {SearchTab? tab}) async {
    final activeTab = tab ?? state.activeTab;
    try {
      switch (activeTab) {
        case SearchTab.all:
          final result = await ref.read(searchAllUseCaseProvider).call(query);
          state = state.copyWith(
            isLoading: false,
            allResult: result,
            clearError: true,
          );
          break;
        case SearchTab.tracks:
          final results = await ref
              .read(searchTracksUseCaseProvider)
              .call(
                query,
                page: 1,
                limit: _pageSize,
                filters: state.trackFilters,
              );
          state = state.copyWith(
            isLoading: false,
            tracks: results,
            hasMore: results.length >= _pageSize,
            clearError: true,
          );
          break;
        case SearchTab.profiles:
          final results = await ref
              .read(searchProfilesUseCaseProvider)
              .call(
                query,
                page: 1,
                limit: _pageSize,
                filters: state.peopleFilters,
              );
          state = state.copyWith(
            isLoading: false,
            profiles: results,
            hasMore: results.length >= _pageSize,
            clearError: true,
          );
          break;
        case SearchTab.playlists:
          final results = await ref
              .read(searchPlaylistsUseCaseProvider)
              .call(
                query,
                page: 1,
                limit: _pageSize,
                filters: state.collectionFilters,
              );
          state = state.copyWith(
            isLoading: false,
            playlists: results,
            hasMore: results.length >= _pageSize,
            clearError: true,
          );
          break;
        case SearchTab.albums:
          final results = await ref
              .read(searchAlbumsUseCaseProvider)
              .call(
                query,
                page: 1,
                limit: _pageSize,
                filters: state.collectionFilters,
              );
          state = state.copyWith(
            isLoading: false,
            albums: results,
            hasMore: results.length >= _pageSize,
            clearError: true,
          );
          break;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed. Please try again.',
      );
    }
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

// ─── Genre detail provider ────────────────────────────────────────────────────
// Riverpod 3.x: NotifierProvider.family factory receives (ref, arg).
// The arg is passed to the notifier via its constructor — NOT via build().
// Notifier.build() always takes zero parameters in Riverpod 3.

class GenreDetailState {
  const GenreDetailState({
    this.detail,
    this.isLoading = true,
    this.activeTab = SearchTab.all,
    this.error,
  });

  final GenreDetailEntity? detail;
  final bool isLoading;
  final SearchTab activeTab;
  final String? error;

  GenreDetailState copyWith({
    GenreDetailEntity? detail,
    bool? isLoading,
    SearchTab? activeTab,
    String? error,
    bool clearError = false,
  }) {
    return GenreDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      activeTab: activeTab ?? this.activeTab,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class GenreDetailNotifier extends Notifier<GenreDetailState> {
  GenreDetailNotifier(this._genreId);

  final String _genreId;

  @override
  GenreDetailState build() {
    Future.microtask(() => _load(_genreId));
    return const GenreDetailState(isLoading: true);
  }

  Future<void> _load(String genreId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await ref
          .read(getGenreDetailUseCaseProvider)
          .call(genreId);
      state = state.copyWith(isLoading: false, detail: detail);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load genre details.',
      );
    }
  }

  void setActiveTab(SearchTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  void retry() {
    _load(_genreId);
  }
}

final genreDetailProvider =
    NotifierProvider.family<GenreDetailNotifier, GenreDetailState, String>(
      (genreId) => GenreDetailNotifier(genreId),
    );
