import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/storage/safe_secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/storage/token_storage.dart';
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

  late GetListeningHistoryUsecase _getHistory;
  late PlayerRepository _repository;

  /// The user ID active when this notifier was built. Every cache read/write
  /// is namespaced under this ID so switching accounts never leaks one user's
  /// history into another's view.
  String _userId = '';

  final List<HistoryTrack> _optimisticTracks = <HistoryTrack>[];
  bool _clearedLocally = false;
  // Watermark recorded by clearHistory().  When non-null, any backend track
  // whose playedAt is on-or-before this instant is dropped on load — that's
  // how the client protects itself from a backend that silently failed to
  // honour the clear request and keeps re-serving the old history.
  DateTime? _clearedAt;

  // ── Per-user storage key helpers ──────────────────────────────────────────
  // All three keys are suffixed with the current user ID so that signing in
  // as a different account never reads the previous user's cached history,
  // clear-flag, or watermark timestamp.

  String get _historyKey =>
      _userId.isEmpty
          ? StorageKeys.cachedListeningHistory
          : '${StorageKeys.cachedListeningHistory}_$_userId';

  String get _clearedLocallyKey =>
      _userId.isEmpty
          ? StorageKeys.historyClearedLocally
          : '${StorageKeys.historyClearedLocally}_$_userId';

  String get _clearedAtKey =>
      _userId.isEmpty
          ? StorageKeys.historyClearedAt
          : '${StorageKeys.historyClearedAt}_$_userId';

  @override
  Future<ListeningHistoryState> build() async {
    _repository = ref.watch(playerRepositoryProvider);
    _getHistory = GetListeningHistoryUsecase(_repository);

    // Scope every cache key to the signed-in user so account switches never
    // bleed one user's history into another's.
    _userId = (await const TokenStorage().getUser())?.id.trim() ?? '';

    // When the device comes back online, flush any queued playback events and
    // pull the latest history from the server so local and remote stay in sync.
    ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
      final wasOffline = previous?.asData?.value == false;
      final isOnlineNow = next.asData?.value == true;
      if (wasOffline && isOnlineNow) {
        refresh();
      }
    });

    final cachedTracks = await _readCachedTracks();
    _clearedLocally = await _readClearedLocally();
    _clearedAt = await _readClearedAt();

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
      // Drop any backend rows whose playedAt predates a previous clear.
      // Defensive against a backend that silently failed to honour clear and
      // keeps re-serving the pre-clear list.
      final backendTracks = _filterByClearWatermark(
        await _getHistory(page: 1, limit: _pageSize),
      );
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
      _clearedAt = await _readClearedAt();

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

      final backendTracks = _filterByClearWatermark(
        await _getHistory(page: 1, limit: _pageSize),
      );
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
      final newTracks = _filterByClearWatermark(
        await _getHistory(page: nextPage, limit: _pageSize),
      );
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
    // A new play resumes normal activity → the clear watermark is no longer
    // meaningful. _persistLocalState below will delete the on-disk key as
    // part of its wasClearedLocally:false branch.
    _clearedAt = null;
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

  // Called when a track has been deleted on the backend (soft-delete).
  // Scrubs it from the in-memory list, the optimistic buffer, and the cached
  // copy in secure storage — so the "recently played" view doesn't keep
  // resurrecting a track that no longer exists. No-op if absent.
  /// Updates only the locally saved resume position for an existing history item.
  ///
  /// This is the key part of Priority 2: Flutter keeps the user's
  /// last listened position locally, so Recently Played / History can resume
  /// from the right second even if the backend never stores progress.
  Future<void> updateTrackProgress(
    String trackId,
    int positionSeconds,
  ) async {
    final safePosition = positionSeconds < 0 ? 0 : positionSeconds;

    HistoryTrack updateOne(HistoryTrack track) {
      if (track.trackId != trackId) return track;
      final max = track.durationSeconds > 0 ? track.durationSeconds : safePosition;
      final clamped = safePosition.clamp(0, max).toInt();
      return track.copyWith(
        lastPositionSeconds: clamped,
        playedAt: DateTime.now(),
      );
    }

    var touched = false;
    for (var i = 0; i < _optimisticTracks.length; i++) {
      if (_optimisticTracks[i].trackId == trackId) {
        _optimisticTracks[i] = updateOne(_optimisticTracks[i]);
        touched = true;
        break;
      }
    }

    final current = state.asData?.value;
    if (current != null) {
      final nextTracks = current.tracks.map((track) {
        if (track.trackId == trackId) touched = true;
        return updateOne(track);
      }).toList(growable: false);

      if (touched) {
        state = AsyncData(current.copyWith(tracks: nextTracks));
        await _persistLocalState(
          nextTracks,
          wasClearedLocally: current.wasClearedLocally,
        );
        return;
      }
    }

    final cached = await _readCachedTracks();
    final nextCached = cached.map((track) {
      if (track.trackId == trackId) touched = true;
      return updateOne(track);
    }).toList(growable: false);

    if (touched) {
      await _persistLocalState(nextCached, wasClearedLocally: _clearedLocally);
    }
  }

  Future<void> removeTrack(String trackId) async {
    _optimisticTracks.removeWhere((track) => track.trackId == trackId);

    final current = state.asData?.value;
    if (current == null) {
      // Still update the on-disk cache in case the provider is rebuilt later.
      final cached = await _readCachedTracks();
      final cleaned = cached.where((t) => t.trackId != trackId).toList();
      if (cleaned.length != cached.length) {
        await _persistLocalState(cleaned, wasClearedLocally: false);
      }
      return;
    }

    final filtered = current.tracks
        .where((track) => track.trackId != trackId)
        .toList();

    // Nothing to do if the track wasn't in the list.
    if (filtered.length == current.tracks.length) return;

    state = AsyncData(current.copyWith(tracks: filtered));
    await _persistLocalState(filtered, wasClearedLocally: false);
  }

  Future<void> clearHistory() async {
    _optimisticTracks.clear();
    _clearedLocally = true;
    // Stamp the moment of clear.  Used by build()/refresh() to ignore any
    // backend entries with playedAt <= this timestamp, so a backend that
    // never received (or silently dropped) the clear request can't
    // resurrect the user's old history on next launch.
    _clearedAt = DateTime.now();

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
    final chosen = secondary.playedAt.isAfter(primary.playedAt)
        ? secondary
        : primary;
    final other = identical(chosen, primary) ? secondary : primary;
    if (chosen.lastPositionSeconds <= 0 && other.lastPositionSeconds > 0) {
      return chosen.copyWith(lastPositionSeconds: other.lastPositionSeconds);
    }
    return chosen;
  }

  /// Drops backend tracks whose playedAt is on-or-before the local clear
  /// watermark, so a backend that lost (or ignored) the clear request can't
  /// resurrect the user's old history on the next launch.  No-op if the
  /// user has never cleared (watermark = null).
  List<HistoryTrack> _filterByClearWatermark(List<HistoryTrack> tracks) {
    final watermark = _clearedAt;
    if (watermark == null) return tracks;
    return tracks
        .where((t) => t.playedAt.isAfter(watermark))
        .toList(growable: false);
  }

  List<HistoryTrack> _applyOptimisticTo(List<HistoryTrack> tracks) {
    // Build the final list with a single seen-set so:
    //   - optimistic entries always come first (most recent activity)
    //   - any duplicate trackId in `tracks` is collapsed to one entry
    //   - any duplicate trackId between optimistic and `tracks` keeps the
    //     optimistic version (it has the freshest playedAt)
    //
    // Bug-fix note: previously the filter and concat preserved duplicates
    // that already existed inside `tracks`.  The user reported the same song
    // appearing twice in History, and the cleanest guard is here at the
    // funnel point that produces the list the UI actually renders.
    final seen = <String>{};
    final result = <HistoryTrack>[];

    for (final track in _optimisticTracks) {
      if (seen.add(track.trackId)) result.add(track);
    }
    for (final track in tracks) {
      if (seen.add(track.trackId)) result.add(track);
    }

    return result;
  }

  void _rememberOptimisticTrack(HistoryTrack track) {
    final existingIdx = _optimisticTracks.indexWhere(
      (t) => t.trackId == track.trackId,
    );

    if (existingIdx != -1) {
      final existing = _optimisticTracks.removeAt(existingIdx);
      final merged = track.copyWith(
        lastPositionSeconds: track.lastPositionSeconds > 0
            ? track.lastPositionSeconds
            : existing.lastPositionSeconds,
      );
      _optimisticTracks.insert(0, merged);
      return;
    }

    _optimisticTracks.insert(0, track);
  }

  Future<void> _persistLocalState(
    List<HistoryTrack> tracks, {
    required bool wasClearedLocally,
  }) async {
    await SafeSecureStorage.write(
      key: _historyKey,
      value: jsonEncode(tracks.map(_historyTrackToJson).toList()),
    );

    if (wasClearedLocally) {
      await SafeSecureStorage.write(
        key: _clearedLocallyKey,
        value: 'true',
      );
      // Watermark in lockstep with the flag so build()/refresh() can drop
      // any backend rows older than the moment of clear, even if the
      // backend's own clear request silently failed.
      if (_clearedAt != null) {
        await SafeSecureStorage.write(
          key: _clearedAtKey,
          value: _clearedAt!.toIso8601String(),
        );
      }
    } else {
      // Resumed normal activity (e.g. a new trackPlayed) — drop both the
      // flag AND the watermark so future plays aren't filtered out.
      await SafeSecureStorage.delete(_clearedLocallyKey);
      await SafeSecureStorage.delete(_clearedAtKey);
    }
  }

  Future<List<HistoryTrack>> _readCachedTracks() async {
    final raw = await SafeSecureStorage.read(_historyKey);
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
      await SafeSecureStorage.delete(_historyKey);
      return const <HistoryTrack>[];
    }
  }

  Future<bool> _readClearedLocally() async {
    final raw = await SafeSecureStorage.read(_clearedLocallyKey);
    return raw == 'true';
  }

  Future<DateTime?> _readClearedAt() async {
    final raw = await SafeSecureStorage.read(_clearedAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
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
      'lastPositionSeconds': track.lastPositionSeconds,
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
          // Sentinel: epoch means "we don't know when". This makes the clear
          // watermark filter (build/refresh/loadMore) correctly DROP this
          // record instead of keeping it (DateTime.now() always passed the
          // filter, so old cached tracks with missing playedAt would resurrect
          // after the user cleared their history).
          DateTime.fromMillisecondsSinceEpoch(0),
      durationSeconds: (json['durationSeconds'] as int?) ?? 0,
      status: _statusFromString((json['status'] ?? 'playable').toString()),
      coverUrl: json['coverUrl'] as String?,
      genre: json['genre'] as String?,
      releaseDate: json['releaseDate'] == null
          ? null
          : DateTime.tryParse(json['releaseDate'].toString()),
      lastPositionSeconds:
          (json['lastPositionSeconds'] as int?) ??
          ((json['positionSeconds'] as num?)?.round() ?? 0),
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
