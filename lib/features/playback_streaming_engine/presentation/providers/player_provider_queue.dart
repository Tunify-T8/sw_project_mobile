part of 'player_provider.dart';

extension PlayerNotifierQueue on PlayerNotifier {
  Future<void> next() async {
    final current = _current;
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
    if (current?.queue == null) return;

    final queue = current!.queue!;
    if (index < 0 || index >= queue.trackIds.length) return;

    await _jumpToIndex(index, queue, autoPlay: current.isPlaying);
  }

  Future<void> buildAndLoadQueue({
    required PlaybackContextType contextType,
    required String contextId,
    required String startTrackId,
    bool shuffle = false,
    RepeatMode repeat = RepeatMode.none,
    String? privateToken,
    bool autoPlay = true,
  }) async {
    final queue = await _buildQueue(
      PlaybackContextRequest(
        contextType: contextType,
        contextId: contextId,
        startTrackId: startTrackId,
        shuffle: shuffle,
        repeat: repeat,
      ),
    );

    await loadTrack(
      startTrackId,
      privateToken: privateToken,
      queue: queue,
      autoPlay: autoPlay,
      seedTrack: _seedTrackForTrackId(startTrackId),
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
    if (index <= queue.currentIndex || index >= queue.trackIds.length) return;

    final newIds = List<String>.from(queue.trackIds)..removeAt(index);
    final next = current.copyWith(queue: queue.copyWith(trackIds: newIds));
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
}
