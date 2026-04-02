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
    this.wasClearedLocally = false,
  });

  final List<HistoryTrack> tracks;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool wasClearedLocally;

  ListeningHistoryState copyWith({
    List<HistoryTrack>? tracks,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? wasClearedLocally,
  }) {
    return ListeningHistoryState(
      tracks: tracks ?? this.tracks,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      wasClearedLocally: wasClearedLocally ?? this.wasClearedLocally,
    );
  }
}

class ListeningHistoryNotifier extends AsyncNotifier<ListeningHistoryState> {
  static const int _pageSize = 20;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  late GetListeningHistoryUsecase _getHistory;
  late PlayerRepository _repository;

  final List<HistoryTrack> _optimisticTracks = <HistoryTrack>[];
  bool _clearedLocally = false;

  @override
  Future<ListeningHistoryState> build() async {
    _repository = ref.watch(playerRepositoryProvider);
    _getHistory = GetListeningHistoryUsecase(_repository);

    final cachedTracks = await _readCachedTracks();
    _clearedLocally = await _readClearedLocally();

    if (_clearedLocally) {
      final localTracks = _applyOptimisticTo(const <HistoryTrack>[]);
      await _persistLocalState(localTracks, wasClearedLocally: true);

      return ListeningHistoryState(
        tracks: localTracks,
        currentPage: 1,
        hasMore: false,
        wasClearedLocally: true,
      );
    }

    try {
      final backendTracks = await _getHistory(page: 1, limit: _pageSize);
      final merged = _mergeLoadedTracks(
        backendTracks: backendTracks,
        cachedTracks: cachedTracks,
      );

      await _persistLocalState(merged, wasClearedLocally: false);

      return ListeningHistoryState(
        tracks: merged,
        currentPage: 1,
        hasMore: backendTracks.length >= _pageSize,
        wasClearedLocally: false,
      );
    } catch (_) {
      final fallback = _applyOptimisticTo(cachedTracks);

      return ListeningHistoryState(
        tracks: fallback,
        currentPage: 1,
        hasMore: cachedTracks.length >= _pageSize,
        wasClearedLocally: false,
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
      final cachedTracks = await _readCachedTracks();
      _clearedLocally = await _readClearedLocally();

      if (_clearedLocally) {
        final localTracks = _applyOptimisticTo(const <HistoryTrack>[]);
        await _persistLocalState(localTracks, wasClearedLocally: true);

        return ListeningHistoryState(
          tracks: localTracks,
          currentPage: 1,
          hasMore: false,
          isRefreshing: false,
          wasClearedLocally: true,
        );
      }

      final backendTracks = await _getHistory(page: 1, limit: _pageSize);
      final merged = _mergeLoadedTracks(
        backendTracks: backendTracks,
        cachedTracks: cachedTracks,
      );

      await _persistLocalState(merged, wasClearedLocally: false);

      return ListeningHistoryState(
        tracks: merged,
        currentPage: 1,
        hasMore: backendTracks.length >= _pageSize,
        isRefreshing: false,
        wasClearedLocally: false,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null ||
        current.wasClearedLocally ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;

    try {
      final newTracks = await _getHistory(page: nextPage, limit: _pageSize);
      final existingIds = current.tracks.map((track) => track.trackId).toSet();

      final uniqueNewTracks = newTracks
          .where((track) => !existingIds.contains(track.trackId))
          .toList(growable: false);

      final updatedTracks = [...current.tracks, ...uniqueNewTracks];

      await _persistLocalState(updatedTracks, wasClearedLocally: false);

      state = AsyncData(
        current.copyWith(
          tracks: updatedTracks,
          currentPage: nextPage,
          hasMore: newTracks.length >= _pageSize,
          isLoadingMore: false,
          wasClearedLocally: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  /// Called immediately when a track begins playing.
  Future<void> trackPlayed(
    HistoryTrack track, {
    bool needsBackendSync = false,
  }) async {
    _clearedLocally = false;
    _rememberOptimisticTrack(track);

    final current = state.asData?.value;
    final nextTracks = _applyOptimisticTo(
      current?.tracks ?? const <HistoryTrack>[],
    );

    final nextState = ListeningHistoryState(
      tracks: nextTracks,
      currentPage: current?.currentPage ?? 1,
      hasMore: current?.hasMore ?? true,
      isLoadingMore: current?.isLoadingMore ?? false,
      isRefreshing: false,
      wasClearedLocally: false,
    );

    state = AsyncData(nextState);

    await _persistLocalState(nextTracks, wasClearedLocally: false);

    // Reserved for backend sync later if/when your backend exposes it again.
    if (needsBackendSync) {
      // no-op for now
    }
  }

  Future<void> clearHistory() async {
    _optimisticTracks.clear();
    _clearedLocally = true;

    state = const AsyncData(
      ListeningHistoryState(
        tracks: <HistoryTrack>[],
        currentPage: 1,
        hasMore: false,
        wasClearedLocally: true,
      ),
    );

    await _persistLocalState(
      const <HistoryTrack>[],
      wasClearedLocally: true,
    );

    try {
      await _repository.clearListeningHistory();
    } catch (_) {
      // Backend clear endpoint may not exist yet.
      // Local clear still works.
    }
  }

  List<HistoryTrack> _mergeLoadedTracks({
    required List<HistoryTrack> backendTracks,
    required List<HistoryTrack> cachedTracks,
  }) {
    final result = <HistoryTrack>[];
    final seen = <String>{};
    final cachedById = {
      for (final track in cachedTracks) track.trackId: track,
    };

    for (final backendTrack in backendTracks) {
      final cached = cachedById[backendTrack.trackId];
      final chosen = _pickNewerTrack(backendTrack, cached);
      if (seen.add(chosen.trackId)) {
        result.add(chosen);
      }
    }

    for (final cachedTrack in cachedTracks) {
      if (seen.add(cachedTrack.trackId)) {
        result.add(cachedTrack);
      }
    }

    return _applyOptimisticTo(result);
  }

  HistoryTrack _pickNewerTrack(HistoryTrack primary, HistoryTrack? secondary) {
    if (secondary == null) return primary;
    return secondary.playedAt.isAfter(primary.playedAt) ? secondary : primary;
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

  Future<void> _persistLocalState(
    List<HistoryTrack> tracks, {
    required bool wasClearedLocally,
  }) async {
    await _storage.write(
      key: StorageKeys.cachedListeningHistory,
      value: jsonEncode(tracks.map(_historyTrackToJson).toList()),
    );

    if (wasClearedLocally) {
      await _storage.write(
        key: StorageKeys.historyClearedLocally,
        value: 'true',
      );
    } else {
      await _storage.delete(key: StorageKeys.historyClearedLocally);
    }
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

  Future<bool> _readClearedLocally() async {
    final raw = await _storage.read(key: StorageKeys.historyClearedLocally);
    return raw == 'true';
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
    final artistJson =
        json['artist'] as Map<String, dynamic>? ?? const <String, dynamic>{};

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
      playedAt:
          DateTime.tryParse((json['playedAt'] ?? '').toString()) ??
          DateTime.now(),
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
      default:
        return PlaybackStatus.playable;
    }
  }
}

final listeningHistoryProvider =
    AsyncNotifierProvider<ListeningHistoryNotifier, ListeningHistoryState>(
      ListeningHistoryNotifier.new,
    );