part of 'queue_screen.dart';

// ── Body ─────────────────────────────────────────────────────────────────────

class _QueueBody extends ConsumerWidget {
  const _QueueBody({this.playerState});

  final PlayerState? playerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundle = playerState?.bundle;
    final queue = playerState?.queue;
    final isRepeatOne = queue?.repeat == RepeatMode.one;
    final historyState = ref.watch(listeningHistoryProvider).asData?.value;
    final historyTracks = historyState?.tracks ?? const [];

    // History: recent tracks that are NOT the currently playing track
    final currentId = bundle?.trackId;
    final historyItems = historyTracks
        .where((t) => t.trackId != currentId)
        .take(3)
        .toList();

    // Playing next: queue tracks after current index
    final queueNextIds = <String>[];
    if (queue != null && queue.trackIds.isNotEmpty) {
      final start = queue.currentIndex + 1;
      if (start < queue.trackIds.length) {
        queueNextIds.addAll(queue.trackIds.sublist(start));
      }
    }

    return ListView(
      children: [
        // ── History (hidden in repeat-one mode) ───────────────────────────
        if (!isRepeatOne && historyItems.isNotEmpty) ...[
          _SectionLabelWithAction(
            label: 'History',
            actionLabel: 'Clear',
            onAction: () => _confirmClearHistory(context, ref),
          ),
          for (final track in historyItems)
            _HistoryTile(track: track, historyTracks: historyTracks),
        ],

        // ── Currently playing ─────────────────────────────────────────────
        if (bundle != null) ...[
          _SectionLabel('Currently playing'),
          _NowPlayingRow(bundle: bundle),
        ],

        // ── Playing next (hidden in repeat-one mode) ──────────────────────
        if (!isRepeatOne) ...[
          _SectionLabel('Playing next'),
          if (queueNextIds.isNotEmpty)
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex -= 1;
                ref
                    .read(playerProvider.notifier)
                    .reorderQueue(oldIndex, newIndex);
              },
              children: [
                for (int i = 0; i < queueNextIds.length; i++)
                  _QueueTrackTile(
                    key: ValueKey(queueNextIds[i]),
                    index: i,
                    trackId: queueNextIds[i],
                    onTap: () => ref
                        .read(playerProvider.notifier)
                        .jumpToQueueIndex((queue?.currentIndex ?? 0) + 1 + i),
                    onRemove: () => ref
                        .read(playerProvider.notifier)
                        .removeFromQueue((queue?.currentIndex ?? 0) + 1 + i),
                  ),
              ],
            )
          else
            const _EmptyNextHint(),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

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
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Section label with action button ──────────────────────────────────────────

class _SectionLabelWithAction extends StatelessWidget {
  const _SectionLabelWithAction({
    required this.label,
    required this.actionLabel,
    required this.onAction,
  });

  final String label;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── History tile ──────────────────────────────────────────────────────────────

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.track, required this.historyTracks});

  final HistoryTrack track;
  final List<HistoryTrack> historyTracks;

  Future<void> _playFromHistory(WidgetRef ref) async {
    final playableHistory = historyTracks
        .where((item) => item.status != PlaybackStatus.blocked)
        .toList(growable: false);
    final queueTrackIds = playableHistory
        .map((item) => item.trackId)
        .toList(growable: false);
    final startIndex = queueTrackIds.indexOf(track.trackId);

    final seedTrack = PlayerSeedTrack(
      trackId: track.trackId,
      title: track.title,
      artistName: track.artist.name,
      durationSeconds: track.durationSeconds,
      coverUrl: track.coverUrl,
    );

    final notifier = ref.read(playerProvider.notifier);
    if (startIndex >= 0 && queueTrackIds.length > 1) {
      await notifier.loadTrack(
        track.trackId,
        autoPlay: true,
        seedTrack: seedTrack,
        queue: PlaybackQueue(
          trackIds: queueTrackIds,
          currentIndex: startIndex,
          shuffle: false,
          repeat: RepeatMode.none,
          source: QueueSource.history,
        ),
      );
      return;
    }

    await notifier.loadTrack(
      track.trackId,
      autoPlay: true,
      seedTrack: seedTrack,
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () => _playFromHistory(ref),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: _Cover(url: track.coverUrl, size: 48),
      title: Text(
        track.title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artist.name,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: GestureDetector(
        onTap: () {
          showTrackOptionsSheet(
            context,
            info: TrackOptionInfo.fromHistory(track),
            ref: ref,
          );
        },
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.more_horiz, color: Colors.white54, size: 20),
        ),
      ),
    );
  }
}

// ── Now playing row ───────────────────────────────────────────────────────────

class _NowPlayingRow extends StatelessWidget {
  const _NowPlayingRow({required this.bundle});

  final dynamic bundle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _Cover(url: bundle.coverUrl as String?, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text(
                      'Now Playing',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  bundle.title as String? ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  bundle.artist?.name as String? ?? '',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.equalizer, color: AppColors.primary, size: 18),
        ],
      ),
    );
  }
}

// ── Queue track tile (Playing next) ───────────────────────────────────────────
//
// What was wrong before:
// 1) The red "Remove" area was visible even when the row was in its normal state.
//    That happened because the foreground row was not forced to fully cover
//    the stack width.
// 2) After opening the remove state, there was no easy way to cancel except
//    removing the track.
//
// What this version does:
// - The foreground row always fills the whole width.
// - The red "Remove" background only appears when the row is revealed.
// - Pressing the red minus opens/closes remove mode.
// - Pressing the right drag-handle while revealed cancels and returns to normal.
// - Tapping the row while revealed also cancels instead of opening the song.

class _QueueTrackTile extends ConsumerStatefulWidget {
  const _QueueTrackTile({
    required super.key,
    required this.index,
    required this.trackId,
    required this.onTap,
    required this.onRemove,
  });

  final int index;
  final String trackId;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  ConsumerState<_QueueTrackTile> createState() => _QueueTrackTileState();
}

class _QueueTrackTileState extends ConsumerState<_QueueTrackTile>
    with SingleTickerProviderStateMixin {
  static const double _removeActionWidth = 104;
  late final AnimationController _revealController;

  bool get _isRevealed => _revealController.value > 0.5;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  void _openReveal() {
    _revealController.forward();
  }

  void _closeReveal() {
    _revealController.reverse();
  }

  void _toggleReveal() {
    if (_isRevealed) {
      _closeReveal();
    } else {
      _openReveal();
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _resolveTrackInfo(widget.trackId, ref);

    return SizedBox(
      key: widget.key,
      height: 72,
      child: AnimatedBuilder(
        animation: _revealController,
        builder: (context, child) {
          final revealProgress = _revealController.value;
          final slideOffset = -_removeActionWidth * revealProgress;
          final showRemoveBackground = revealProgress > 0.0;

          return ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (showRemoveBackground)
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: _removeActionWidth,
                      child: Material(
                        color: const Color(0xFFE53935),
                        child: InkWell(
                          onTap: () {
                            _closeReveal();
                            widget.onRemove();
                          },
                          child: const Center(
                            child: Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(slideOffset, 0),
                  child: Container(
                    color: const Color(0xFF111111),
                    child: ListTile(
                      onTap: _isRevealed ? _closeReveal : widget.onTap,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _toggleReveal,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE53935),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _Cover(url: info.coverUrl, size: 44),
                        ],
                      ),
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            info.artist,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: _isRevealed
                          ? GestureDetector(
                              onTap: _closeReveal,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.drag_handle,
                                  color: Colors.white54,
                                  size: 20,
                                ),
                              ),
                            )
                          : ReorderableDragStartListener(
                              index: widget.index,
                              child: const Icon(
                                Icons.drag_handle,
                                color: Colors.white38,
                                size: 20,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Shared cover widget ───────────────────────────────────────────────────────

class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: url != null && url!.isNotEmpty
          ? Image.network(
              url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF2A2A2A),
      child: const Icon(Icons.music_note, color: Colors.white24, size: 20),
    );
  }
}

// ── Track info resolver ───────────────────────────────────────────────────────

class _TrackInfo {
  const _TrackInfo({
    required this.title,
    required this.artist,
    this.coverUrl,
  });

  final String title;
  final String artist;
  final String? coverUrl;
}

_TrackInfo _resolveTrackInfo(String trackId, WidgetRef ref) {
  // 1. GlobalTrackStore (uploaded tracks — fastest, in-memory)
  final stored = ref.read(globalTrackStoreProvider).find(trackId);
  if (stored != null) {
    return _TrackInfo(
      title: stored.title,
      artist: stored.artistDisplay,
      coverUrl: stored.artworkUrl,
    );
  }

  // 2. Listening history
  final historyTracks =
      ref.read(listeningHistoryProvider).asData?.value.tracks ?? const [];
  for (final t in historyTracks) {
    if (t.trackId == trackId) {
      return _TrackInfo(
        title: t.title,
        artist: t.artist.name,
        coverUrl: t.coverUrl,
      );
    }
  }

  // 3. Fall back to ID (unknown track not yet in local stores)
  return const _TrackInfo(title: 'Track', artist: '');
}