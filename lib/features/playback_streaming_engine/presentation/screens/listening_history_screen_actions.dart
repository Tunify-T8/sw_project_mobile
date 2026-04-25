part of 'listening_history_screen.dart';

extension _ListeningHistoryScreenActions on ListeningHistoryScreen {
  Future<void> _confirmClearHistory(
    BuildContext context,
    WidgetRef ref,
  ) async {
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
    final seedTrack = _seedTrackFromHistory(track, stored);

    // Opened from Listening history → "next up" should be the next song
    // in the user's history, not "more by this artist". We build the queue
    // from the playable history tracks and anchor it at the tapped track.
    // The queue is marked with QueueSource.history so
    // enrichQueueWithArtistTracks will skip it and leave the order intact.
    final playableHistory = historyTracks
        .where((item) => item.status != PlaybackStatus.blocked)
        .toList(growable: false);
    final queueTrackIds = playableHistory
        .map((item) => item.trackId)
        .toList(growable: false);
    final startIndex = queueTrackIds.indexOf(track.trackId);

    if (startIndex >= 0 && queueTrackIds.length > 1) {
      await ref.read(playerProvider.notifier).loadTrack(
            track.trackId,
            autoPlay: true,
            seedTrack: seedTrack,
            initialPositionSeconds: track.lastPositionSeconds.toDouble(),
            queue: PlaybackQueue(
              trackIds: queueTrackIds,
              currentIndex: startIndex,
              shuffle: false,
              repeat: RepeatMode.none,
              source: QueueSource.history,
            ),
          );
    } else {
      await ref.read(playerProvider.notifier).loadTrack(
            track.trackId,
            autoPlay: true,
            seedTrack: seedTrack,
            initialPositionSeconds: track.lastPositionSeconds.toDouble(),
          );
    }

    if (!context.mounted) return;

    final current = ref.read(playerProvider).asData?.value;
    final item = current != null && current.bundle != null
        ? uploadItemFromPlayerState(current, store)
        : (stored ?? _historyTrackToUploadItem(track));

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => TrackDetailScreen(item: item),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 340),
      ),
    );
  }

  PlayerSeedTrack _seedTrackFromHistory(
    HistoryTrack track,
    UploadItem? stored,
  ) {
    return PlayerSeedTrack(
      trackId: track.trackId,
      title: stored?.title ?? track.title,
      artistName: stored?.artistDisplay ?? track.artist.name,
      durationSeconds:
          stored?.durationSeconds ??
          (track.durationSeconds > 0 ? track.durationSeconds : 0),
      coverUrl: stored?.artworkUrl ?? track.coverUrl,
      waveformUrl: stored?.waveformUrl,
      directAudioUrl: stored?.audioUrl,
      resumePositionSeconds: track.lastPositionSeconds,
      localFilePath: stored?.localFilePath,
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
