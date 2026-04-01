part of 'listening_history_screen.dart';

extension _ListeningHistoryScreenActions on ListeningHistoryScreen {
  Future<void> _openTrack(
    BuildContext context,
    WidgetRef ref,
    List<HistoryTrack> historyTracks,
    HistoryTrack track,
  ) async {
    if (track.status == PlaybackStatus.blocked) return;

    final trackIds = historyTracks
        .map((item) => item.trackId)
        .toList(growable: false);
    final currentIndex = trackIds.indexOf(track.trackId);
    final store = ref.read(globalTrackStoreProvider);
    final stored = storedUploadItemForTrack(store, track.trackId);

    if (stored != null) {
      final queueItems = _storedQueueItems(store, historyTracks);
      await openUploadItemPlayer(
        context,
        ref,
        stored,
        queueItems: queueItems.isEmpty ? null : queueItems,
        openScreen: true,
      );
      return;
    }

    await ref
        .read(playerProvider.notifier)
        .loadTrackWithQueue(
          trackId: track.trackId,
          trackIds: trackIds,
          currentIndex: currentIndex < 0 ? 0 : currentIndex,
          autoPlay: true,
        );
    if (!context.mounted) return;
    await openCurrentPlaybackTrackSurface(context, ref);
  }

  List<UploadItem> _storedQueueItems(
    GlobalTrackStore store,
    List<HistoryTrack> historyTracks,
  ) {
    return historyTracks
        .map((track) => storedUploadItemForTrack(store, track.trackId))
        .whereType<UploadItem>()
        .toList(growable: false);
  }
}
