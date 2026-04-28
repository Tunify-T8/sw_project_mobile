import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:software_project/core/network/dio_client.dart';
import '../../data/api/discovery_api.dart';
import '../../data/repository/mock_search_repository_impl.dart';
import '../../data/repository/real_search_repository_impl.dart';
import '../../data/services/mock_search_service.dart';
import '../../domain/entities/autocomplete_result_entity.dart';
import '../../domain/entities/genre_detail_entity.dart';
import '../../domain/entities/search_all_result_entity.dart';
import '../../domain/entities/search_filters_entity.dart';
import '../../domain/entities/search_genre_entity.dart';
import '../../domain/entities/top_result_entity.dart';
import '../../domain/entities/album_result_entity.dart';
import '../../domain/entities/playlist_result_entity.dart';
import '../../domain/entities/profile_result_entity.dart';
import '../../domain/entities/track_result_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/search_usecases.dart';
import '../../domain/usecases/search_autocomplete_usecase.dart';
import 'package:flutter/foundation.dart';

// ─── Recent result kinds ──────────────────────────────────────────────────────

enum RecentResultKind { track, album, playlist, profile }

class RecentResultItem {
  const RecentResultItem({
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
    this.artworkUrl,
    this.isCertified = false,
    this.track,
  });

  final RecentResultKind kind;
  final String id;
  final String title;
  final String subtitle;
  final String? artworkUrl;
  final bool isCertified;

  /// Attached for track items so tapping a recently-played card can replay it.
  final TrackResultEntity? track;

  bool get isUnavailable => false;
}

// ─── Repository / mock switch ─────────────────────────────────────────────────

const bool useMock = false;

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  if (useMock) {
    return MockSearchRepositoryImpl(MockSearchService());
  }
  return RealSearchRepositoryImpl(DiscoveryApi(ref.read(dioProvider)));
});

// ─── Use-case providers ───────────────────────────────────────────────────────

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

/// FIX (M8-020): Dedicated autocomplete use-case — uses /search/autocomplete.
final searchAutocompleteUseCaseProvider = Provider(
  (ref) => SearchAutocompleteUseCase(ref.read(searchRepositoryProvider)),
);

// ─── Enums ────────────────────────────────────────────────────────────────────

enum SearchScreenMode { idle, typing, results }

enum SearchTab { all, tracks, profiles, playlists, albums }

// ─── State ────────────────────────────────────────────────────────────────────

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
  final List<RecentResultItem> recentResults;
  final List<String> typingSuggestions;
  final TrackSearchFilters trackFilters;
  final CollectionSearchFilters collectionFilters;
  final PeopleSearchFilters peopleFilters;

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

// ─── Notifier ─────────────────────────────────────────────────────────────────

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
    state = state.copyWith(
      query: query,
      mode: SearchScreenMode.typing,
      typingSuggestions: _computeSuggestionsFromState(query),
    );
    if (query.trim().isNotEmpty) {
      _debouncedAutocomplete(query.trim());
    } else {
      state = state.copyWith(typingSuggestions: []);
    }
  }

  Timer? _debounce;

  void _debouncedAutocomplete(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final result = await ref
            .read(searchAutocompleteUseCaseProvider)
            .call(query);
        if (state.query == query && state.mode == SearchScreenMode.typing) {
          state = state.copyWith(
            typingSuggestions: _suggestionsFromAutocomplete(query, result),
          );
        }
      } catch (_) {
        // Fallback: local suggestions already shown — silent no-op.
      }
    });
  }

  List<String> _suggestionsFromAutocomplete(
    String query,
    AutocompleteResultEntity result,
  ) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    final seen = <String>{};
    final exact = <String>[];
    final partial = <String>[];

    void add(String s) {
      if (s.isEmpty) return;
      if (!seen.add(s.toLowerCase())) return;
      if (s.toLowerCase().startsWith(q)) {
        exact.add(s);
      } else if (s.toLowerCase().contains(q)) {
        partial.add(s);
      }
    }

    for (final t in result.tracks) {
      add(t.title);
      add(t.artist);
    }
    for (final u in result.users) {
      add(u.displayLabel);
      if (u.displayName != null && u.displayName!.isNotEmpty) add(u.username);
    }
    for (final c in result.collections) {
      add(c.title);
    }
    return [...exact, ...partial].take(8).toList();
  }

  List<String> _computeSuggestionsFromState(String query) {
    if (query.trim().length < 2) return [];
    final q = query.toLowerCase();
    final seen = <String>{};
    final exact = <String>[];
    final partial = <String>[];

    void add(String s) {
      if (s.isEmpty) return;
      if (!seen.add(s.toLowerCase())) return;
      if (s.toLowerCase().startsWith(q)) {
        exact.add(s);
      } else if (s.toLowerCase().contains(q)) {
        partial.add(s);
      }
    }

    for (final t in state.tracks) {
      add(t.title);
      add(t.artistName);
    }
    for (final p in state.profiles) {
      add(p.displayLabel);
    }
    for (final a in state.albums) {
      add(a.title);
      add(a.artistName);
    }
    for (final pl in state.playlists) {
      add(pl.title);
    }
    if (state.allResult?.topResult != null) {
      add(state.allResult!.topResult!.title);
    }
    return [...exact, ...partial].take(8).toList();
  }

  // ── Query submission ───────────────────────────────────────────────────────

  Future<void> onQuerySubmitted(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _debounce?.cancel();

    state = state.copyWith(
      mode: SearchScreenMode.results,
      query: trimmed,
      isLoading: true,
      clearError: true,
      clearAllResult: true,
      tracks: [],
      profiles: [],
      playlists: [],
      albums: [],
      page: 1,
      hasMore: true,
    );

    _addRecentSearch(trimmed);

    try {
      final raw = await ref.read(searchAllUseCaseProvider).call(trimmed);
      final result = _reScoreTopResult(raw, trimmed);
      state = state.copyWith(isLoading: false, allResult: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed. Please try again.',
      );
    }
  }

  Future<void> onRecentSearchTapped(String query) => onQuerySubmitted(query);

  void onSearchCleared() {
    _debounce?.cancel();
    state = state.copyWith(
      mode: SearchScreenMode.typing,
      query: '',
      typingSuggestions: [],
      clearError: true,
    );
  }

  void onSearchDismissed() {
    _debounce?.cancel();
    state = state.copyWith(
      mode: SearchScreenMode.idle,
      query: '',
      typingSuggestions: [],
      clearError: true,
    );
  }

  // ── Tab / filter management ────────────────────────────────────────────────

  Future<void> setActiveTab(SearchTab tab) async {
    if (state.query.isEmpty) return;
    state = state.copyWith(
      activeTab: tab,
      isLoading: true,
      clearError: true,
      page: 1,
      hasMore: true,
    );
    await _loadActiveTab(state.query, tab: tab);
  }

  void setTrackFilters(TrackSearchFilters filters) {
    state = state.copyWith(trackFilters: filters);
    if (state.query.isNotEmpty) _reloadCurrentTab();
  }

  void setCollectionFilters(CollectionSearchFilters filters) {
    state = state.copyWith(collectionFilters: filters);
    if (state.query.isNotEmpty) _reloadCurrentTab();
  }

  void setPeopleFilters(PeopleSearchFilters filters) {
    state = state.copyWith(peopleFilters: filters);
    if (state.query.isNotEmpty) _reloadCurrentTab();
  }

  Future<void> _reloadCurrentTab() async {
    final query = state.query;
    if (query.isEmpty) return;
    state = state.copyWith(isLoading: true, page: 1, hasMore: true);
    try {
      switch (state.activeTab) {
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
            hasMore: results.length == _pageSize,
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
            hasMore: results.length == _pageSize,
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
            hasMore: results.length == _pageSize,
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
            hasMore: results.length == _pageSize,
          );
          break;
        default:
          state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  // ── Pagination ─────────────────────────────────────────────────────────────

  Future<void> loadMore() async {
    if (state.activeTab == SearchTab.all) return;
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final query = state.query;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);

    try {
      switch (state.activeTab) {
        case SearchTab.tracks:
          final results = await ref
              .read(searchTracksUseCaseProvider)
              .call(
                query,
                page: nextPage,
                limit: _pageSize,
                filters: state.trackFilters,
              );
          state = state.copyWith(
            isLoadingMore: false,
            tracks: [...state.tracks, ...results],
            page: nextPage,
            hasMore: results.length == _pageSize,
          );
          break;
        case SearchTab.profiles:
          final results = await ref
              .read(searchProfilesUseCaseProvider)
              .call(
                query,
                page: nextPage,
                limit: _pageSize,
                filters: state.peopleFilters,
              );
          state = state.copyWith(
            isLoadingMore: false,
            profiles: [...state.profiles, ...results],
            page: nextPage,
            hasMore: results.length == _pageSize,
          );
          break;
        case SearchTab.playlists:
          final results = await ref
              .read(searchPlaylistsUseCaseProvider)
              .call(
                query,
                page: nextPage,
                limit: _pageSize,
                filters: state.collectionFilters,
              );
          state = state.copyWith(
            isLoadingMore: false,
            playlists: [...state.playlists, ...results],
            page: nextPage,
            hasMore: results.length == _pageSize,
          );
          break;
        case SearchTab.albums:
          final results = await ref
              .read(searchAlbumsUseCaseProvider)
              .call(
                query,
                page: nextPage,
                limit: _pageSize,
                filters: state.collectionFilters,
              );
          state = state.copyWith(
            isLoadingMore: false,
            albums: [...state.albums, ...results],
            page: nextPage,
            hasMore: results.length == _pageSize,
          );
          break;
        default:
          state = state.copyWith(isLoadingMore: false);
      }
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> _loadActiveTab(String query, {SearchTab? tab}) async {
    final activeTab = tab ?? state.activeTab;
    debugPrint(
      '[SearchProvider] _loadActiveTab: tab=$activeTab query="$query"',
    );
    try {
      switch (activeTab) {
        case SearchTab.all:
          final raw = await ref.read(searchAllUseCaseProvider).call(query);
          final result = _reScoreTopResult(raw, query);
          debugPrint(
            '[SearchProvider] all → tracks:${result.tracks.length} profiles:${result.profiles.length} playlists:${result.playlists.length} albums:${result.albums.length}',
          );
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
          debugPrint(
            '[SearchProvider] tracks endpoint → ${results.length} results',
          );
          // Seed from allResult when the dedicated endpoint returns empty.
          final seeded = results.isNotEmpty
              ? results
              : (state.allResult?.tracks ?? const []);
          debugPrint(
            '[SearchProvider] tracks using ${results.isNotEmpty ? "endpoint" : "allResult seed"}: ${seeded.length}',
          );
          state = state.copyWith(
            isLoading: false,
            tracks: seeded,
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
          debugPrint(
            '[SearchProvider] profiles endpoint → ${results.length} results',
          );
          final seeded = results.isNotEmpty
              ? results
              : (state.allResult?.profiles ?? const []);
          debugPrint(
            '[SearchProvider] profiles using ${results.isNotEmpty ? "endpoint" : "allResult seed"}: ${seeded.length}',
          );
          state = state.copyWith(
            isLoading: false,
            profiles: seeded,
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
          debugPrint(
            '[SearchProvider] playlists endpoint → ${results.length} results',
          );
          final seeded = results.isNotEmpty
              ? results
              : (state.allResult?.playlists ?? const []);
          debugPrint(
            '[SearchProvider] playlists using ${results.isNotEmpty ? "endpoint" : "allResult seed"}: ${seeded.length}',
          );
          state = state.copyWith(
            isLoading: false,
            playlists: seeded,
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
          debugPrint(
            '[SearchProvider] albums endpoint → ${results.length} results',
          );
          final seeded = results.isNotEmpty
              ? results
              : (state.allResult?.albums ?? const []);
          debugPrint(
            '[SearchProvider] albums using ${results.isNotEmpty ? "endpoint" : "allResult seed"}: ${seeded.length}',
          );
          state = state.copyWith(
            isLoading: false,
            albums: seeded,
            hasMore: results.length >= _pageSize,
            clearError: true,
          );
          break;
      }
    } catch (e, st) {
      debugPrint(
        '[SearchProvider] _loadActiveTab ERROR tab=$activeTab: $e\n$st',
      );
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed. Please try again.',
      );
    }
  }

  // ── Recent results ─────────────────────────────────────────────────────────

  void recordResultTapped(RecentResultItem item) {
    final updated = [
      item,
      ...state.recentResults.where((r) => r.id != item.id),
    ].take(8).toList();
    state = state.copyWith(recentResults: updated);
  }

  void recordTrackPlayed(TrackResultEntity track) {
    recordResultTapped(
      RecentResultItem(
        kind: RecentResultKind.track,
        id: track.id,
        title: track.title,
        subtitle: track.artistName,
        artworkUrl: track.artworkUrl,
        track: track,
      ),
    );
  }

  /// Called by [LibraryUploadsNotifier] when a track is deleted (M8-015B) or
  /// made private (M8-017) so the stale entry is immediately removed from the
  /// "Recently Played" row on the search All tab.
  void invalidateTrackFromRecents(String trackId) {
    state = state.copyWith(
      recentResults: state.recentResults.where((r) => r.id != trackId).toList(),
    );
  }

  void removeRecentResult(RecentResultItem item) {
    state = state.copyWith(
      recentResults: state.recentResults.where((r) => r.id != item.id).toList(),
    );
  }

  void clearRecentResults() => state = state.copyWith(recentResults: []);

  void removeRecentSearch(String query) {
    state = state.copyWith(
      recentSearches: state.recentSearches.where((s) => s != query).toList(),
    );
  }

  void clearRecentSearches() => state = state.copyWith(recentSearches: []);

  void _addRecentSearch(String query) {
    final updated = [
      query,
      ...state.recentSearches.where((s) => s != query),
    ].take(8).toList();
    state = state.copyWith(recentSearches: updated);
  }

  // ── Top-result re-scoring ──────────────────────────────────────────────────

  SearchAllResultEntity _reScoreTopResult(
    SearchAllResultEntity result,
    String query,
  ) {
    // If the backend already picked a top result AND this is an exact match,
    // trust it — don't re-rank.
    final q = query.toLowerCase().trim();

    int score(String text) {
      final t = text.toLowerCase();
      if (t == q) return 100;
      if (t.startsWith(q)) return 70;
      if (t.contains(q)) return 40;
      return 0;
    }

    // Also check displayLabel for profiles (covers displayName).
    int profileScore(ProfileResultEntity p) {
      final s1 = score(p.username);
      final s2 = score(p.displayLabel);
      return s1 > s2 ? s1 : s2;
    }

    // ── Find the best candidate across all types ─────────────────────────────
    // Priority rule when scores are equal:
    //   profile > playlist > album > track
    // This means: if you search a username, the profile wins at equal score.
    // A track only beats a profile if it scores strictly higher.

    int bestScore = 0;
    TopResultEntity? bestTop;

    // 1. Profiles — checked first, so equal-score ties go to profile.
    for (final p in result.profiles) {
      final s = profileScore(p);
      if (s > bestScore) {
        bestScore = s;
        bestTop = TopResultEntity(
          id: p.id,
          type: TopResultType.profile,
          title: p.displayLabel,
          subtitle: '${_fmtCount(p.followersCount)} Followers',
          artworkUrl: p.avatarUrl,
        );
      }
    }

    // 2. Playlists — beat profile only if strictly higher score.
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

    // 3. Albums.
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

    // 4. Tracks — lowest priority at equal score.
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

    // If nothing scored, keep the original backend top result.
    if (bestTop == null) return result;

    return SearchAllResultEntity(
      topResult: bestTop,
      tracks: result.tracks,
      playlists: result.playlists,
      albums: result.albums,
      profiles: result.profiles,
    );
  }

  String _fmtCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

// ─── Genre detail ─────────────────────────────────────────────────────────────

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

  void setActiveTab(SearchTab tab) => state = state.copyWith(activeTab: tab);

  void retry() => _load(_genreId);
}

final genreDetailProvider =
    NotifierProvider.family<GenreDetailNotifier, GenreDetailState, String>(
      (genreId) => GenreDetailNotifier(genreId),
    );
