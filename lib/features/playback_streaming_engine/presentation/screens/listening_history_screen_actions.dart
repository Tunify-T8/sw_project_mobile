part of 'listening_history_screen.dart';

extension _ListeningHistoryScreenActions on ListeningHistoryScreen {
  Future<void> _openTrack(
    BuildContext context,
    WidgetRef ref,
    List<HistoryTrack> historyTracks,
    HistoryTrack track,
  ) async {
    if (track.status == PlaybackStatus.blocked) return;

    final store = ref.read(globalTrackStoreProvider);

    final queueItems = historyTracks
        .where((item) => item.status != PlaybackStatus.blocked)
        .map(
          (item) => _historyTrackToUploadItem(
            item,
            storedUploadItemForTrack(store, item.trackId),
          ),
        )
        .toList(growable: false);

    final selected = _historyTrackToUploadItem(
      track,
      storedUploadItemForTrack(store, track.trackId),
    );

    await openUploadItemPlayer(
      context,
      ref,
      selected,
      queueItems: queueItems,
      openScreen: true,
    );
  }

  UploadItem _historyTrackToUploadItem(
    HistoryTrack track,
    UploadItem? stored,
  ) {
    if (stored != null) {
      return stored;
    }

    return UploadItem(
      id: track.trackId,
      title: track.title,
      artistDisplay: track.artist.name,
      durationLabel: _formatDuration(track.durationSeconds),
      durationSeconds: track.durationSeconds,
      audioUrl: null,
      waveformUrl: null,
      artworkUrl: track.coverUrl,
      localFilePath: null,
      description: '',
      visibility: UploadVisibility.public,
      status: UploadProcessingStatus.finished,
      isExplicit: false,
      createdAt: track.playedAt,
    );
  }

  String _formatDuration(int totalSeconds) {
    final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = safeSeconds ~/ 60;
    final seconds = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
