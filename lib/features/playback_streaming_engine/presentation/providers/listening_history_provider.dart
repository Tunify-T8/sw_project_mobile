import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/history_track.dart';
import '../../domain/usecases/get_listening_history_usecase.dart';
import 'player_repository_provider.dart';

class ListeningHistoryState {
  const ListeningHistoryState({
    this.tracks = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.pendingSyncIds = const [],
  });

  final List<HistoryTrack> tracks;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  /// Track IDs that were played locally and may not be visible on the backend
  /// yet. These are kept at the top until a refresh confirms the backend now
  /// includes them.
  final List<String> pendingSyncIds;

  ListeningHistoryState copyWith({
    List<HistoryTrack>? tracks,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    List<String>? pendingSyncIds,
  }) {
    return ListeningHistoryState(
      tracks: tracks ?? this.tracks,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      pendingSyncIds: pendingSyncIds ?? this.pendingSyncIds,
    );
  }
}

class ListeningHistoryNotifier extends AsyncNotifier<ListeningHistoryState> {
  late GetListeningHistoryUsecase _getHistory;

  static const int _pageSize = 20;

  /// Optimistic items are stored outside `state` too, so history updates still
  /// work even if the screen is not currently visible or the provider is
  /// between loading states.
  final List<HistoryTrack> _optimisticTracks = <HistoryTrack>[];

  @override
  Future<ListeningHistoryState> build() async {
    final repo = ref.watch(playerRepositoryProvider);
    _getHistory = GetListeningHistoryUsecase(repo);

    final backendTracks = await _getHistory(page: 1, limit: _pageSize);
    final merged = _mergeTopPage(backendTracks);

    return ListeningHistoryState(
      tracks: merged,
      currentPage: 1,
      hasMore: backendTracks.length >= _pageSize,
      pendingSyncIds: _optimisticTracks.map((track) => track.trackId).toList(),
    );
  }

  Future<void> refresh() async {
    final previous = state.asData?.value;

    if (previous != null) {
      state = AsyncData(previous.copyWith(isRefreshing: true));
    } else {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(() async {
      final backendTracks = await _getHistory(page: 1, limit: _pageSize);
      final merged = _mergeTopPage(backendTracks);

      return ListeningHistoryState(
        tracks: merged,
        currentPage: 1,
        hasMore: backendTracks.length >= _pageSize,
        isRefreshing: false,
        pendingSyncIds: _optimisticTracks.map((track) => track.trackId).toList(),
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;

    try {
      final newTracks = await _getHistory(page: nextPage, limit: _pageSize);
      final existingIds = current.tracks.map((track) => track.trackId).toSet();
      final uniqueNewTracks = newTracks
          .where((track) => !existingIds.contains(track.trackId))
          .toList(growable: false);

      state = AsyncData(
        current.copyWith(
          tracks: [...current.tracks, ...uniqueNewTracks],
          currentPage: nextPage,
          hasMore: newTracks.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  /// Called immediately when a track begins playing. This updates the list at
  /// once instead of waiting for pause/refresh/backend confirmation.
  void trackPlayed(HistoryTrack track) {
    _rememberOptimisticTrack(track);

    final current = state.asData?.value;
    if (current == null) {
      state = AsyncData(
        ListeningHistoryState(
          tracks: [track],
          currentPage: 1,
          hasMore: true,
          pendingSyncIds: _optimisticTracks.map((item) => item.trackId).toList(),
        ),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(
        tracks: _applyOptimisticTo(current.tracks),
        pendingSyncIds: _optimisticTracks.map((item) => item.trackId).toList(),
      ),
    );
  }

  List<HistoryTrack> _mergeTopPage(List<HistoryTrack> backendTracks) {
    final backendIds = backendTracks.map((track) => track.trackId).toSet();

    _optimisticTracks.removeWhere((track) => backendIds.contains(track.trackId));

    return [
      ..._optimisticTracks,
      ...backendTracks.where(
        (track) => !_optimisticTracks.any((local) => local.trackId == track.trackId),
      ),
    ];
  }

  List<HistoryTrack> _applyOptimisticTo(List<HistoryTrack> tracks) {
    final filtered = tracks
        .where(
          (track) => !_optimisticTracks.any(
            (local) => local.trackId == track.trackId,
          ),
        )
        .toList(growable: false);

    return [..._optimisticTracks, ...filtered];
  }

  void _rememberOptimisticTrack(HistoryTrack track) {
    _optimisticTracks.removeWhere((item) => item.trackId == track.trackId);
    _optimisticTracks.insert(0, track);
  }
}

final listeningHistoryProvider =
    AsyncNotifierProvider<ListeningHistoryNotifier, ListeningHistoryState>(
  ListeningHistoryNotifier.new,
);
