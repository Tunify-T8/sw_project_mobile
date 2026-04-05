part of 'player_provider.dart';

extension PlayerNotifierQueue on PlayerNotifier {
  Future<void> next() async {
    final current = _current;
    if (current?.queue == null) return;

    final queue = current!.queue!;
    if (queue.trackIds.length <= 1) return;

    final nextIndex = queue.currentIndex + 1;
    final resolvedIndex = nextIndex >= queue.trackIds.length ? 0 : nextIndex;

    await _jumpToIndex(resolvedIndex, queue, autoPlay: current.isPlaying);
  }

  Future<void> previous() async {
    final current = _current;
    if (current?.queue == null) return;

    final queue = current!.queue!;
    if (queue.trackIds.length <= 1) return;

    final previousIndex = queue.currentIndex - 1;
    final resolvedIndex =
        previousIndex < 0 ? queue.trackIds.length - 1 : previousIndex;

    await _jumpToIndex(resolvedIndex, queue, autoPlay: current.isPlaying);
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
    // Only allow removing tracks after the current one.
    if (index <= queue.currentIndex || index >= queue.trackIds.length) return;

    final newIds = List<String>.from(queue.trackIds)..removeAt(index);
    _setPlayerState(current.copyWith(queue: queue.copyWith(trackIds: newIds)));
    unawaited(_persistCurrentSession(playerState: current.copyWith(queue: queue.copyWith(trackIds: newIds)), force: true));
  }

  /// Appends [trackId] to the end of the queue. If there is no queue yet,
  /// creates one with the currently playing track followed by the new one.
  void addToQueue(String trackId) {
    final current = _current;
    if (current == null) return;

    if (current.queue == null) {
      final currentTrackId = current.bundle?.trackId;
      if (currentTrackId == null) return;
      final newQueue = PlaybackQueue(
        trackIds: [currentTrackId, trackId],
        currentIndex: 0,
        shuffle: false,
        repeat: RepeatMode.none,
      );
      final next = current.copyWith(queue: newQueue);
      _setPlayerState(next);
      unawaited(_persistCurrentSession(playerState: next, force: true));
    } else {
      final queue = current.queue!;
      final newIds = List<String>.from(queue.trackIds)..add(trackId);
      final next = current.copyWith(queue: queue.copyWith(trackIds: newIds));
      _setPlayerState(next);
      unawaited(_persistCurrentSession(playerState: next, force: true));
    }
  }

  /// Reorders a queued track. [oldIndex] and [newIndex] are both relative to
  /// the tracks AFTER the currently playing track (i.e. the "Playing next" list).
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
