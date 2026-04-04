import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/mock_search_repository_impl.dart';
import '../../data/services/mock_search_service.dart';
import '../../domain/entities/search_all_result_entity.dart';
import '../../domain/entities/top_result_entity.dart';
import '../../domain/entities/album_result_entity.dart';
import '../../domain/entities/genre_detail_entity.dart';
import '../../domain/entities/search_genre_entity.dart';
import '../../domain/entities/playlist_result_entity.dart';
import '../../domain/entities/profile_result_entity.dart';
import '../../domain/entities/track_result_entity.dart';
import '../../domain/entities/search_filters_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/search_usecases.dart';

//when backend is ready
import '../../data/repository/real_search_repository_impl.dart';
import '../../data/api/discovery_api.dart';
import '../../../../core/network/dio_client.dart';

// ─── Recent result item — what shows in the typing/recent list ────────────────
// Mirrors what the real SoundCloud app shows: the actual result tapped,
// not just the search string. Sorted by: profiles first, then tracks, then albums.

enum RecentResultKind { track, profile, album, playlist }

class RecentResultItem {
  const RecentResultItem({
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
    this.artworkUrl,
    this.isVerified = false,
  });

  final RecentResultKind kind;
  final String id;
  final String title; // track title / username / album title
  final String subtitle; // artist / followers / track count
  final String? artworkUrl;
  final bool isVerified;
}

// ─── Repository provider ──────────────────────────────────────────────────────

// ─── Mock/Real switch ────────────────────────────────────────────────────────
// Set to false when backend is ready. One line change, nothing else needed.
const bool useMock = false;

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  if (useMock) {
    return MockSearchRepositoryImpl(MockSearchService());
  }
  return RealSearchRepositoryImpl(DiscoveryApi(ref.read(dioProvider)));
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
    this.recentResults = const [],
    this.typingSuggestions = const [],
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
  // Actual result items shown in the recent list (replaces plain strings in UI)
  final List<RecentResultItem> recentResults;
  // Live suggestions while typing — filtered from current results
  final List<String> typingSuggestions;
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
    bool clearAllResult = false,
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
    List<RecentResultItem>? recentResults,
    List<String>? typingSuggestions,
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
      allResult: clearAllResult ? null : allResult ?? this.allResult,
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
      recentResults: recentResults ?? this.recentResults,
      typingSuggestions: typingSuggestions ?? this.typingSuggestions,
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
    final suggestions = _computeSuggestions(query);
    state = state.copyWith(
      query: query,
      mode: SearchScreenMode.typing,
      typingSuggestions: suggestions,
    );
  }

  // Build live suggestions while typing.
  // Pulls from the static genre/mock data so suggestions appear immediately
  // without needing a network call. When backend lands, replace with API call.
  List<String> _computeSuggestions(String query) {
    if (query.trim().length < 2) return [];
    final q = query.toLowerCase();
    final seen = <String>{};
    final exact = <String>[]; // starts with query
    final partial = <String>[]; // just contains query

    void add(String s) {
      if (!seen.add(s.toLowerCase())) return;
      if (s.toLowerCase().startsWith(q)) {
        exact.add(s);
      } else if (s.toLowerCase().contains(q)) {
        partial.add(s);
      }
    }

    // Pull from already-loaded results if any
    for (final t in state.tracks) {
      add(t.title);
      add(t.artistName);
    }
    for (final p in state.profiles) {
      add(p.username);
    }
    for (final a in state.albums) {
      add(a.title);
      add(a.artistName);
    }
    for (final pl in state.playlists) {
      add(pl.title);
    }

    // Always supplement with hardcoded pool so suggestions appear from first char
    const pool = [
      'don toliver',
      'don omar',
      'doja cat',
      'donia wael',
      'dont call me today',
      "don't let me down",
      "don't stop the music",
      "don't you need somebody",
      'dont speak no doubt',
      'dont stop believin',
      'octane',
      'ocean drive',
      'one dance',
      'old town road',
      'hip hop',
      'healing era',
      'house music',
      'indie pop',
      'rock classics',
      'r&b hits',
      'pop hits',
      'party mix',
      'chill vibes',
      'workout playlist',
      'latin mix',
      'feel good music',
    ];
    for (final s in pool) {
      add(s);
    }

    return [...exact, ...partial].take(8).toList();
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
        clearAllResult: true,
      tracks: [],
      profiles: [],
      playlists: [],
      albums: [],
      page: 1,
      hasMore: true,
    );
    await _loadActiveTab(trimmed);
  }

  // X button: clear text but stay in typing mode (show recent searches)
  void onSearchCleared() {
    state = state.copyWith(
      query: '',
      mode: SearchScreenMode.typing, // stay in typing — show recent searches
      typingSuggestions: [],
      clearError: true,
        clearAllResult: true,
      tracks: [],
      profiles: [],
      playlists: [],
      albums: [],
    );
  }

  // Back arrow from results → typing (show recent searches)
  // Back arrow from typing → idle (genre grid)
  void onSearchDismissed() {
    if (state.mode == SearchScreenMode.results) {
      state = state.copyWith(
        mode: SearchScreenMode.typing,
        typingSuggestions: [],
        clearError: true,
      );
    } else {
      // From typing → idle
      state = state.copyWith(
        mode: SearchScreenMode.idle,
        query: '',
        typingSuggestions: [],
        clearError: true,
      );
    }
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

  // ── Recent results (actual items tapped, not just search strings) ─────────

  void removeRecentResult(RecentResultItem item) {
    state = state.copyWith(
      recentResults: state.recentResults.where((r) => r.id != item.id).toList(),
    );
  }

  void clearRecentResults() => state = state.copyWith(recentResults: []);

  /// Called when user taps a result tile — adds it to recents.
  void recordResultTapped(RecentResultItem item) {
    final updated = [
      item,
      ...state.recentResults.where((r) => r.id != item.id),
    ].take(8).toList();
    state = state.copyWith(recentResults: updated);
  }

  Future<void> _loadActiveTab(String query, {SearchTab? tab}) async {
    final activeTab = tab ?? state.activeTab;
    try {
      switch (activeTab) {
        case SearchTab.all:
          final raw = await ref.read(searchAllUseCaseProvider).call(query);
          // Re-score top result based on query similarity
          final result = _reScoreTopResult(raw, query);
          state = state.copyWith(
            isLoading: false,
            allResult: result,
            clearError: true,
          );
          _autoRecordTopResult(result);
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

  // Re-score the top result based on query similarity.
  // Scoring: exact match = 100, starts with = 70, contains = 40.
  // Checks against: track titles, album titles, profile usernames.
  // If query matches an album/track title more closely than a profile,
  // the album/track becomes the top result.
  SearchAllResultEntity _reScoreTopResult(
    SearchAllResultEntity result,
    String query,
  ) {
    final q = query.toLowerCase().trim();

    int score(String text) {
      final t = text.toLowerCase();
      if (t == q) return 100;
      if (t.startsWith(q)) return 70;
      if (t.contains(q)) return 40;
      return 0;
    }

    // Score each candidate
    int bestScore = 0;
    TopResultEntity? bestTop;

    // Albums first — "octane" should surface the album
    for (final a in result.albums) {
      final s = score(a.title);
      if (s > bestScore) {
        bestScore = s;
        bestTop = TopResultEntity(
          id: a.id,
          type: TopResultType.album,
          title: a.title,
          subtitle: '${a.artistName} · Album · ${a.trackCount} Tracks',
          artworkUrl: a.artworkUrl,
        );
      }
    }

    // Tracks
    for (final t in result.tracks) {
      final s = score(t.title);
      if (s > bestScore) {
        bestScore = s;
        bestTop = TopResultEntity(
          id: t.id,
          type: TopResultType.track,
          title: t.title,
          subtitle: t.artistName,
          artworkUrl: t.artworkUrl,
        );
      }
    }

    // Profiles — give profiles a boost if the whole query matches a name
    for (final p in result.profiles) {
      // Profiles get +10 bonus because users usually search for artists
      final s = score(p.username) + 10;
      if (s > bestScore) {
        bestScore = s;
        bestTop = TopResultEntity(
          id: p.id,
          type: TopResultType.profile,
          title: p.username,
          subtitle: '${p.followersCount} Followers',
          artworkUrl: p.avatarUrl,
        );
      }
    }

    // Playlists
    for (final pl in result.playlists) {
      final s = score(pl.title);
      if (s > bestScore) {
        bestScore = s;
        bestTop = TopResultEntity(
          id: pl.id,
          type: TopResultType.playlist,
          title: pl.title,
          subtitle: pl.creatorName,
          artworkUrl: pl.artworkUrl,
        );
      }
    }

    if (bestTop == null) return result;

    return SearchAllResultEntity(
      topResult: bestTop,
      tracks: result.tracks,
      playlists: result.playlists,
      albums: result.albums,
      profiles: result.profiles,
    );
  }

  void _autoRecordTopResult(SearchAllResultEntity result) {
    // Add the top result to the "Recent Searches" typed list (profiles included)
    final top = result.topResult;
    if (top == null) return;

    final searchItem = RecentResultItem(
      kind: _kindFromTopType(top.type),
      id: top.id,
      title: top.title,
      subtitle: top.subtitle,
      artworkUrl: top.artworkUrl,
      isVerified: top.type == TopResultType.profile,
    );
    recordResultTapped(searchItem);

    // Add the FIRST non-profile result to Recently Played (tracks/albums/playlists only)
    RecentResultItem? playedItem;
    if (result.tracks.isNotEmpty) {
      final t = result.tracks.first;
      playedItem = RecentResultItem(
        kind: RecentResultKind.track,
        id: t.id,
        title: t.title,
        subtitle: t.artistName,
        artworkUrl: t.artworkUrl,
      );
    } else if (result.albums.isNotEmpty) {
      final a = result.albums.first;
      playedItem = RecentResultItem(
        kind: RecentResultKind.album,
        id: a.id,
        title: a.title,
        subtitle: a.artistName,
        artworkUrl: a.artworkUrl,
      );
    } else if (result.playlists.isNotEmpty) {
      final pl = result.playlists.first;
      playedItem = RecentResultItem(
        kind: RecentResultKind.playlist,
        id: pl.id,
        title: pl.title,
        subtitle: pl.creatorName,
        artworkUrl: pl.artworkUrl,
      );
    }

    if (playedItem != null) {
      // Store track/album/playlist as a recently played item at the front
      // recentResults stores ALL recent items; Recently Played UI filters profiles out
      final updated = [
        playedItem,
        ...state.recentResults.where((r) => r.id != playedItem!.id),
      ].take(8).toList();
      state = state.copyWith(recentResults: updated);
    }
  }

  RecentResultKind _kindFromTopType(TopResultType type) {
    switch (type) {
      case TopResultType.profile:
        return RecentResultKind.profile;
      case TopResultType.track:
        return RecentResultKind.track;
      case TopResultType.album:
        return RecentResultKind.album;
      case TopResultType.playlist:
        return RecentResultKind.playlist;
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
