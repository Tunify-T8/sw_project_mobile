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
    );
  }

  Future<void> _jumpToIndex(
    int index,
    PlaybackQueue queue, {
    required bool autoPlay,
  }) async {
    final nextQueue = queue.copyWith(currentIndex: index);

    await loadTrack(
      queue.trackIds[index],
      queue: nextQueue,
      autoPlay: autoPlay,
    );
  }
}
