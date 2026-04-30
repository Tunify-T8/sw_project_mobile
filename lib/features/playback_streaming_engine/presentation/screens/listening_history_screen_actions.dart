part of 'listening_history_screen.dart';

extension _ListeningHistoryScreenActions on ListeningHistoryScreen {
  Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171717),
        title: const Text(
          'Clear listening history?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will clear your listening history.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (shouldClear != true) return;
    await ref.read(listeningHistoryProvider.notifier).clearHistory();
  }

  Future<void> _openTrack(
    BuildContext context,
    WidgetRef ref,
    List<HistoryTrack> historyTracks,
    HistoryTrack track,
  ) async {
    if (track.status == PlaybackStatus.blocked) return;

    final store = ref.read(globalTrackStoreProvider);
    final stored = storedUploadItemForTrack(store, track.trackId);
    // Opened from Listening history → "next up" should be the next song
    // in the user's history, not "more by this artist". We build the queue
    // from the playable history tracks and anchor it at the tapped track.
    // The queue is marked with QueueSource.history so
    // enrichQueueWithArtistTracks will skip it and leave the order intact.
    final playableHistory = historyTracks
        .where((item) => item.status != PlaybackStatus.blocked)
        .toList(growable: false);
    await openHistorySourcedPlayer(
      context,
      ref,
      stored ?? _historyTrackToUploadItem(track),
      historyTracks: playableHistory,
      openScreen: true,
      initialPositionSeconds: track.lastPositionSeconds.toDouble(),
    );
  }

  UploadItem _historyTrackToUploadItem(HistoryTrack track) {
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
