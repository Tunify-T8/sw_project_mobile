part of 'player_provider.dart';

extension PlayerNotifierQueue on PlayerNotifier {
  Future<void> next() async {
    final current = _current;
    if (_isLoadingTrack || _isTransportBusy || current?.isBuffering == true) {
      debugPrint("[M5 Player] next ignored while player is busy");
      return;
    }
    if (current?.queue == null) return;

    final queue = current!.queue!;
    if (queue.trackIds.length <= 1) return;

    final nextIndex = queue.currentIndex + 1;

    if (nextIndex >= queue.trackIds.length) {
      if (queue.repeat == RepeatMode.all) {
        await _jumpToIndex(0, queue, autoPlay: current.isPlaying);
      }
      return;
    }

    await _jumpToIndex(nextIndex, queue, autoPlay: current.isPlaying);
  }

  Future<void> previous() async {
    final current = _current;
    if (_isLoadingTrack || _isTransportBusy || current?.isBuffering == true) {
      debugPrint("[M5 Player] previous ignored while player is busy");
      return;
    }
    if (current?.queue == null) return;

    final queue = current!.queue!;
    if (queue.trackIds.length <= 1) return;

    final previousIndex = queue.currentIndex - 1;

    if (previousIndex < 0) {
      if (queue.repeat == RepeatMode.all) {
        await _jumpToIndex(
          queue.trackIds.length - 1,
          queue,
          autoPlay: current.isPlaying,
        );
      }
      return;
    }

    await _jumpToIndex(previousIndex, queue, autoPlay: current.isPlaying);
  }

  Future<void> jumpToQueueIndex(int index) async {
    final current = _current;
    if (_isLoadingTrack || _isTransportBusy || current?.isBuffering == true) {
      debugPrint("[M5 Player] queue jump ignored while player is busy");
      return;
    }
    if (current?.queue == null) return;

    final queue = current!.queue!;
    if (index < 0 || index >= queue.trackIds.length) return;

    await _jumpToIndex(index, queue, autoPlay: true);
  }

  Future<void> buildAndLoadQueue({
    required PlaybackContextType contextType,
    required String contextId,
    required String startTrackId,
    bool shuffle = false,
    RepeatMode repeat = RepeatMode.none,
    String? privateToken,
    bool autoPlay = true,
    PlayerSeedTrack? seedTrack,
  }) async {
    final queue = (await _buildQueue(
      PlaybackContextRequest(
        contextType: contextType,
        contextId: contextId,
        startTrackId: startTrackId,
        shuffle: shuffle,
        repeat: repeat,
      ),
    ))
        .copyWith(source: _queueSourceForContext(contextType));

    await loadTrack(
      startTrackId,
      privateToken: privateToken,
      queue: queue,
      autoPlay: autoPlay,
      seedTrack: seedTrack ?? _seedTrackForTrackId(startTrackId),
    );
  }

  Future<void> _jumpToIndex(
    int index,
    PlaybackQueue queue, {
    required bool autoPlay,
  }) async {
    final nextQueue = queue.copyWith(currentIndex: index);
    final nextTrackId = queue.trackIds[index];

    await loadTrack(
      nextTrackId,
      queue: nextQueue,
      autoPlay: autoPlay,
      seedTrack: _seedTrackForTrackId(nextTrackId),
    );
  }

  void removeFromQueue(int index) {
    final current = _current;
    if (current?.queue == null) return;

    final queue = current!.queue!;
    if (index < 0 || index >= queue.trackIds.length) return;
    if (index == queue.currentIndex) return;

    final newIds = List<String>.from(queue.trackIds)..removeAt(index);
    var newCurrentIndex = queue.currentIndex;
    if (index < queue.currentIndex) {
      newCurrentIndex -= 1;
    }
    if (newCurrentIndex >= newIds.length) {
      newCurrentIndex = newIds.isEmpty ? 0 : newIds.length - 1;
    }

    final next = current.copyWith(
      queue: queue.copyWith(trackIds: newIds, currentIndex: newCurrentIndex),
    );
    _setPlayerState(next);
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }

  /// Backwards-compatible helper. Existing callers that say "add to queue"
  /// should behave like "Play last".
  void addToQueue(String trackId) {
    addToQueueLast(trackId);
  }

  /// Insert a track immediately after the currently playing one.
  ///
  /// This is what users expect from "Play next".
  void addToQueueNext(String trackId) {
    final current = _current;
    if (current == null) {
      unawaited(
        loadTrack(
          trackId,
          autoPlay: true,
          seedTrack: _seedTrackForTrackId(trackId),
        ),
      );
      return;
    }

    final currentTrackId = current.bundle?.trackId;
    if (currentTrackId == null) return;

    if (current.queue == null) {
      final nextQueue = PlaybackQueue(
        trackIds: [currentTrackId, trackId],
        currentIndex: 0,
        shuffle: false,
        repeat: RepeatMode.none,
      );
      final next = current.copyWith(queue: nextQueue);
      _setPlayerState(next);
      unawaited(_persistCurrentSession(playerState: next, force: true));
      return;
    }

    final queue = current.queue!;
    final insertIndex = queue.currentIndex + 1;
    final newIds = List<String>.from(queue.trackIds)..insert(insertIndex, trackId);
    final next = current.copyWith(queue: queue.copyWith(trackIds: newIds));
    _setPlayerState(next);
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }

  /// Append a track to the very end of the queue.
  ///
  /// This is what users expect from "Play last".
  void addToQueueLast(String trackId) {
    final current = _current;
    if (current == null) {
      unawaited(
        loadTrack(
          trackId,
          autoPlay: true,
          seedTrack: _seedTrackForTrackId(trackId),
        ),
      );
      return;
    }

    final currentTrackId = current.bundle?.trackId;
    if (currentTrackId == null) return;

    if (current.queue == null) {
      final nextQueue = PlaybackQueue(
        trackIds: [currentTrackId, trackId],
        currentIndex: 0,
        shuffle: false,
        repeat: RepeatMode.none,
      );
      final next = current.copyWith(queue: nextQueue);
      _setPlayerState(next);
      unawaited(_persistCurrentSession(playerState: next, force: true));
      return;
    }

    final queue = current.queue!;
    final newIds = List<String>.from(queue.trackIds)..add(trackId);
    final next = current.copyWith(queue: queue.copyWith(trackIds: newIds));
    _setPlayerState(next);
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }

  /// Reorders a queued track.
  ///
  /// Both indexes are relative to the visible "Playing next" list,
  /// not the full underlying queue. So we offset them by the current track.
  void reorderQueue(int oldIndex, int newIndex) {
    final current = _current;
    if (current?.queue == null) return;

    final queue = current!.queue!;
    final offset = queue.currentIndex + 1;
    final absOld = offset + oldIndex;
    final absNew = offset + newIndex;

    if (absOld < offset || absOld >= queue.trackIds.length) return;
    if (absNew < offset || absNew > queue.trackIds.length) return;

    final newIds = List<String>.from(queue.trackIds);
    final item = newIds.removeAt(absOld);
    newIds.insert(absNew, item);

    final next = current.copyWith(queue: queue.copyWith(trackIds: newIds));
    _setPlayerState(next);
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }

  /// Asynchronously fetch [artistUserId]'s public catalog and merge the tracks
  /// into the live queue. Called right after a track starts playing so the
  /// "Next up" list populates without blocking the play action itself.
  ///
  /// Behaviour notes:
  ///   - No-op if the user is no longer playing the same track by the time the
  ///     network call returns (they may have skipped to something else).
  ///   - Tracks already in the queue are skipped — we never duplicate.
  ///   - The currently playing track keeps its position; new IDs are appended
  ///     after the current index.
  ///   - When shuffle is on, new IDs append to BOTH the visible (shuffled)
  ///     trackIds AND the originalTrackIds snapshot, so toggling shuffle off
  ///     later doesn't drop them.
  ///   - All errors are swallowed (the API client itself returns [] on failure).
  Future<void> enrichQueueWithArtistTracks({
    required String artistUserId,
    required String anchorTrackId,
  }) async {
    if (artistUserId.trim().isEmpty) return;

    // History-sourced queues are sacred: the user opened the track from
    // Listening history and expects "next" to mean "next in history",
    // NOT "more by this artist". Skip enrichment entirely.
    final currentBeforeFetch = _current;
    if (currentBeforeFetch?.queue?.source == QueueSource.history ||
        currentBeforeFetch?.queue?.source == QueueSource.playlist) {
      return;
    }

    final api = ref.read(userTracksApiProvider);
    final fetched = await api.getUserTracks(artistUserId);
    if (fetched.isEmpty) return;

    // The user may have moved on while the request was in flight.
    final after = _current;
    if (after == null || after.bundle?.trackId != anchorTrackId) return;

    // Double-check source after the async gap — the user may have tapped
    // a history track while the fetch was in flight.
    if (after.queue?.source == QueueSource.history ||
        after.queue?.source == QueueSource.playlist) {
      return;
    }

    final existingQueue = after.queue;
    final existingIds = existingQueue?.trackIds ?? <String>[];
    final existingSet = existingIds.toSet();

    // Keep playable tracks that aren't already queued, and never re-add the
    // currently playing track (it must stay at its current index).
    final newIds = fetched
        .where((t) => t.isPlayable)
        .map((t) => t.id)
        .where((id) => id.isNotEmpty && !existingSet.contains(id))
        .toList(growable: false);

    if (newIds.isEmpty) return;

    if (existingQueue == null) {
      // No queue yet — build a fresh one with the current track at index 0
      // followed by the artist's other tracks.
      final fullIds = <String>[anchorTrackId, ...newIds];
      final newQueue = PlaybackQueue(
        trackIds: fullIds,
        currentIndex: 0,
        shuffle: false,
        repeat: RepeatMode.all,
      );
      final next = after.copyWith(queue: newQueue);
      _setPlayerState(next);
      unawaited(_persistCurrentSession(playerState: next, force: true));
      return;
    }

    // Existing queue — splice the new IDs in after the current index.
    final updatedIds = <String>[
      ...existingIds.sublist(0, existingQueue.currentIndex + 1),
      ...newIds,
      ...existingIds.sublist(existingQueue.currentIndex + 1),
    ];

    // Mirror the additions into the original-order snapshot so unshuffling
    // doesn't lose the freshly fetched tracks.
    final updatedOriginal = existingQueue.originalTrackIds == null
        ? null
        : <String>[...existingQueue.originalTrackIds!, ...newIds];

    final updatedQueue = existingQueue.copyWith(
      trackIds: updatedIds,
      originalTrackIds: updatedOriginal,
    );

    final next = after.copyWith(queue: updatedQueue);
    _setPlayerState(next);
    unawaited(_persistCurrentSession(playerState: next, force: true));
  }

  PlayerSeedTrack? _seedTrackForTrackId(String trackId) {
    final stored = ref.read(globalTrackStoreProvider).find(trackId);
    if (stored != null) {
      return PlayerSeedTrack(
        trackId: stored.id,
        title: stored.title,
        artistName: stored.artistDisplay,
        durationSeconds: stored.durationSeconds,
        coverUrl: stored.artworkUrl,
        waveformUrl: stored.waveformUrl,
        directAudioUrl: stored.audioUrl,
        localFilePath: stored.localFilePath,
      );
    }

    final historyState = ref.read(listeningHistoryProvider).asData?.value;
    final historyTrack = historyState?.tracks.cast<HistoryTrack?>().firstWhere(
          (track) => track?.trackId == trackId,
          orElse: () => null,
        );

    if (historyTrack == null) {
      return null;
    }

    return PlayerSeedTrack(
      trackId: historyTrack.trackId,
      title: historyTrack.title,
      artistName: historyTrack.artist.name,
      durationSeconds: historyTrack.durationSeconds,
      coverUrl: historyTrack.coverUrl,
    );
  }

  QueueSource _queueSourceForContext(PlaybackContextType contextType) {
    switch (contextType) {
      case PlaybackContextType.history:
        return QueueSource.history;
      case PlaybackContextType.playlist:
        return QueueSource.playlist;
      case PlaybackContextType.feed:
      case PlaybackContextType.profile:
        return QueueSource.explicit;
      case PlaybackContextType.track:
        return QueueSource.singleTrack;
    }
  }
}
