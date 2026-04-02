import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/storage_keys.dart';
import '../../domain/entities/history_track.dart';
import '../../domain/entities/playback_status.dart';
import '../../domain/entities/track_artist_summary.dart';
import '../../domain/repositories/player_repository.dart';
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
  static const int _pageSize = 20;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  late GetListeningHistoryUsecase _getHistory;
  late PlayerRepository _repository;

  /// Optimistic items are stored outside `state` too, so history updates still
  /// work even if the screen is not currently visible or the provider is
  /// between loading states.
  final List<HistoryTrack> _optimisticTracks = <HistoryTrack>[];
  final List<String> _pendingSyncIds = <String>[];

  @override
  Future<ListeningHistoryState> build() async {
    _repository = ref.watch(playerRepositoryProvider);
    _getHistory = GetListeningHistoryUsecase(_repository);

    final cachedTracks = await _readCachedTracks();
    final pendingSyncIds = await _readPendingSyncIds();

    _restoreOptimisticTracksFromCache(
      cachedTracks: cachedTracks,
      pendingSyncIds: pendingSyncIds,
    );

    try {
      await _flushPendingHistoryPlays();
      final backendTracks = await _getHistory(page: 1, limit: _pageSize);
      final merged = _mergeTopPage(backendTracks);

      await _persistLocalState(
        tracks: merged,
        pendingSyncIds: List<String>.from(_pendingSyncIds),
      );

      return ListeningHistoryState(
        tracks: merged,
        currentPage: 1,
        hasMore: backendTracks.length >= _pageSize,
        pendingSyncIds: List<String>.from(_pendingSyncIds),
      );
    } catch (_) {
      final merged = _applyOptimisticTo(cachedTracks);

      return ListeningHistoryState(
        tracks: merged,
        currentPage: 1,
        hasMore: cachedTracks.length >= _pageSize,
        pendingSyncIds: List<String>.from(_pendingSyncIds),
      );
    }
  }

  Future<void> refresh() async {
    final previous = state.asData?.value;

    if (previous != null) {
      state = AsyncData(previous.copyWith(isRefreshing: true));
    } else {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(() async {
      await _flushPendingHistoryPlays();
      final backendTracks = await _getHistory(page: 1, limit: _pageSize);
      final merged = _mergeTopPage(backendTracks);
      final pendingIds = List<String>.from(_pendingSyncIds);

      await _persistLocalState(
        tracks: merged,
        pendingSyncIds: pendingIds,
      );

      return ListeningHistoryState(
        tracks: merged,
        currentPage: 1,
        hasMore: backendTracks.length >= _pageSize,
        isRefreshing: false,
        pendingSyncIds: pendingIds,
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

      final updatedTracks = [...current.tracks, ...uniqueNewTracks];

      await _persistLocalState(
        tracks: updatedTracks,
        pendingSyncIds: current.pendingSyncIds,
      );

      state = AsyncData(
        current.copyWith(
          tracks: updatedTracks,
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
  Future<void> trackPlayed(
    HistoryTrack track, {
    bool needsBackendSync = false,
  }) async {
    _rememberOptimisticTrack(track, needsBackendSync: needsBackendSync);

    final current = state.asData?.value;
    final pendingIds = List<String>.from(_pendingSyncIds);

    if (current == null) {
      final localState = ListeningHistoryState(
        tracks: [track],
        currentPage: 1,
        hasMore: true,
        pendingSyncIds: pendingIds,
      );
      state = AsyncData(localState);
      await _persistLocalState(tracks: localState.tracks, pendingSyncIds: pendingIds);
      return;
    }

    final updatedTracks = _applyOptimisticTo(current.tracks);

    state = AsyncData(
      current.copyWith(
        tracks: updatedTracks,
        pendingSyncIds: pendingIds,
      ),
    );

    await _persistLocalState(tracks: updatedTracks, pendingSyncIds: pendingIds);
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

  void _rememberOptimisticTrack(
    HistoryTrack track, {
    required bool needsBackendSync,
  }) {
    _optimisticTracks.removeWhere((item) => item.trackId == track.trackId);
    _optimisticTracks.insert(0, track);

    _pendingSyncIds.removeWhere((id) => id == track.trackId);
    if (needsBackendSync) {
      _pendingSyncIds.insert(0, track.trackId);
    }
  }

  Future<void> _flushPendingHistoryPlays() async {
    final pendingSyncIds = await _readPendingSyncIds();
    if (pendingSyncIds.isEmpty) return;

    final successfulIds = <String>[];

    for (final trackId in pendingSyncIds.reversed) {
      try {
        await _repository.requestStreamUrl(trackId);
        successfulIds.add(trackId);
      } catch (_) {
        // Stop on the first connectivity failure so we keep the remaining
        // pending order intact for the next retry.
        break;
      }
    }

    if (successfulIds.isEmpty) return;

    _optimisticTracks.removeWhere((track) => successfulIds.contains(track.trackId));

    final remainingIds = pendingSyncIds
        .where((id) => !successfulIds.contains(id))
        .toList(growable: false);

    _pendingSyncIds
      ..clear()
      ..addAll(remainingIds);

    await _storage.write(
      key: StorageKeys.pendingHistorySyncTrackIds,
      value: jsonEncode(remainingIds),
    );
  }

  Future<void> _persistLocalState({
    required List<HistoryTrack> tracks,
    required List<String> pendingSyncIds,
  }) async {
    await _storage.write(
      key: StorageKeys.cachedListeningHistory,
      value: jsonEncode(tracks.map(_historyTrackToJson).toList()),
    );

    await _storage.write(
      key: StorageKeys.pendingHistorySyncTrackIds,
      value: jsonEncode(pendingSyncIds),
    );
  }

  Future<List<HistoryTrack>> _readCachedTracks() async {
    final raw = await _storage.read(key: StorageKeys.cachedListeningHistory);
    if (raw == null || raw.isEmpty) {
      return const <HistoryTrack>[];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_historyTrackFromJson)
          .toList(growable: false);
    } catch (_) {
      await _storage.delete(key: StorageKeys.cachedListeningHistory);
      return const <HistoryTrack>[];
    }
  }

  Future<List<String>> _readPendingSyncIds() async {
    final raw = await _storage.read(key: StorageKeys.pendingHistorySyncTrackIds);
    if (raw == null || raw.isEmpty) {
      return const <String>[];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((value) => value.toString()).toList(growable: false);
    } catch (_) {
      await _storage.delete(key: StorageKeys.pendingHistorySyncTrackIds);
      return const <String>[];
    }
  }

  void _restoreOptimisticTracksFromCache({
    required List<HistoryTrack> cachedTracks,
    required List<String> pendingSyncIds,
  }) {
    _optimisticTracks.clear();
    _pendingSyncIds
      ..clear()
      ..addAll(pendingSyncIds);

    for (final id in pendingSyncIds) {
      for (final track in cachedTracks) {
        if (track.trackId == id) {
          _optimisticTracks.add(track);
          break;
        }
      }
    }
  }

  Map<String, dynamic> _historyTrackToJson(HistoryTrack track) {
    return {
      'trackId': track.trackId,
      'title': track.title,
      'artist': {
        'id': track.artist.id,
        'name': track.artist.name,
        'username': track.artist.username,
        'displayName': track.artist.displayName,
        'avatarUrl': track.artist.avatarUrl,
        'tier': track.artist.tier,
      },
      'playedAt': track.playedAt.toIso8601String(),
      'durationSeconds': track.durationSeconds,
      'status': _statusToString(track.status),
      'coverUrl': track.coverUrl,
      'genre': track.genre,
      'releaseDate': track.releaseDate?.toIso8601String(),
      'likeCount': track.likeCount,
      'commentCount': track.commentCount,
      'repostCount': track.repostCount,
      'playCount': track.playCount,
    };
  }

  HistoryTrack _historyTrackFromJson(Map<String, dynamic> json) {
    final artistJson = json['artist'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return HistoryTrack(
      trackId: (json['trackId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      artist: TrackArtistSummary(
        id: (artistJson['id'] ?? '') as String,
        name: (artistJson['name'] ?? '') as String,
        username: artistJson['username'] as String?,
        displayName: artistJson['displayName'] as String?,
        avatarUrl: artistJson['avatarUrl'] as String?,
        tier: artistJson['tier'] as String?,
      ),
      playedAt: DateTime.tryParse((json['playedAt'] ?? '').toString()) ?? DateTime.now(),
      durationSeconds: (json['durationSeconds'] as int?) ?? 0,
      status: _statusFromString((json['status'] ?? 'playable').toString()),
      coverUrl: json['coverUrl'] as String?,
      genre: json['genre'] as String?,
      releaseDate: json['releaseDate'] == null
          ? null
          : DateTime.tryParse(json['releaseDate'].toString()),
      likeCount: (json['likeCount'] as int?) ?? 0,
      commentCount: (json['commentCount'] as int?) ?? 0,
      repostCount: (json['repostCount'] as int?) ?? 0,
      playCount: (json['playCount'] as int?) ?? 0,
    );
  }

  String _statusToString(PlaybackStatus value) {
    switch (value) {
      case PlaybackStatus.playable:
        return 'playable';
      case PlaybackStatus.preview:
        return 'preview';
      case PlaybackStatus.blocked:
        return 'blocked';
    }
  }

  PlaybackStatus _statusFromString(String value) {
    switch (value) {
      case 'preview':
        return PlaybackStatus.preview;
      case 'blocked':
        return PlaybackStatus.blocked;
      case 'playable':
      default:
        return PlaybackStatus.playable;
    }
  }
}

final listeningHistoryProvider =
    AsyncNotifierProvider<ListeningHistoryNotifier, ListeningHistoryState>(
  ListeningHistoryNotifier.new,
);
