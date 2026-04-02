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
