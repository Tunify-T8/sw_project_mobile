import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/history_track.dart';
import '../../domain/usecases/get_listening_history_usecase.dart';
import 'player_repository_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ListeningHistoryState {
  const ListeningHistoryState({
    this.tracks = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<HistoryTrack> tracks;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  ListeningHistoryState copyWith({
    List<HistoryTrack>? tracks,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ListeningHistoryState(
      tracks: tracks ?? this.tracks,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ListeningHistoryNotifier extends AsyncNotifier<ListeningHistoryState> {
  late GetListeningHistoryUsecase _getHistory;

  static const int _pageSize = 20;

  @override
  Future<ListeningHistoryState> build() async {
    final repo = ref.watch(playerRepositoryProvider);
    _getHistory = GetListeningHistoryUsecase(repo);
    return _fetchPage(page: 1, existing: []);
  }

  // -------------------------------------------------------------------------
  // Load first page (also used by pull-to-refresh)
  // -------------------------------------------------------------------------

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchPage(page: 1, existing: []),
    );
  }

  // -------------------------------------------------------------------------
  // Load next page
  // -------------------------------------------------------------------------

  Future<void> loadMore() async {
    // asData?.value works across all Riverpod 2.x (unlike valueOrNull which needs 2.4+)
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;

    try {
      final newTracks = await _getHistory(page: nextPage, limit: _pageSize);
      state = AsyncData(
        current.copyWith(
          tracks: [...current.tracks, ...newTracks],
          currentPage: nextPage,
          hasMore: newTracks.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      // Restore previous state with loading flag cleared on error
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Future<ListeningHistoryState> _fetchPage({
    required int page,
    required List<HistoryTrack> existing,
  }) async {
    final tracks = await _getHistory(page: page, limit: _pageSize);
    return ListeningHistoryState(
      tracks: [...existing, ...tracks],
      currentPage: page,
      hasMore: tracks.length >= _pageSize,
      isLoadingMore: false,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final listeningHistoryProvider =
    AsyncNotifierProvider<ListeningHistoryNotifier, ListeningHistoryState>(
  ListeningHistoryNotifier.new,
);