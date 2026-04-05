part of 'queue_screen.dart';

// ── Body ─────────────────────────────────────────────────────────────────────

class _QueueBody extends ConsumerWidget {
  const _QueueBody({this.playerState});

  final PlayerState? playerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundle = playerState?.bundle;
    final queue = playerState?.queue;
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

    // Suggestions: same-artist history tracks when Playing Next is empty
    List<HistoryTrack> suggestions = const [];
    if (queueNextIds.isEmpty && bundle != null) {
      final artistName = bundle.artist.name;
      final sameArtist = historyTracks
          .where((t) =>
              t.trackId != currentId && t.artist.name == artistName)
          .toList();
      final others = historyTracks
          .where((t) =>
              t.trackId != currentId && t.artist.name != artistName)
          .toList();
      suggestions = [...sameArtist, ...others].take(10).toList();
    }

    return ListView(
      children: [
        // ── History ──────────────────────────────────────────────────────
        if (historyItems.isNotEmpty) ...[
          _SectionLabel('History'),
          for (final track in historyItems)
            _HistoryTile(track: track),
        ],

        // ── Currently playing ─────────────────────────────────────────────
        if (bundle != null) ...[
          _SectionLabel('Currently playing'),
          _NowPlayingRow(bundle: bundle),
        ],

        // ── Playing next ──────────────────────────────────────────────────
        _SectionLabel('Playing next'),
        if (queueNextIds.isNotEmpty)
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex -= 1;
              ref.read(playerProvider.notifier).reorderQueue(oldIndex, newIndex);
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
        else if (suggestions.isNotEmpty)
          ...suggestions.map(
            (t) => _SuggestionTile(
              track: t,
              onAdd: () =>
                  ref.read(playerProvider.notifier).addToQueue(t.trackId),
            ),
          )
        else
          const _EmptyNextHint(),

        const SizedBox(height: 16),
      ],
    );
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

// ── History tile (not tappable) ───────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.track});
  final HistoryTrack track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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

// ── Queue track tile (Playing next) ──────────────────────────────────────────

class _QueueTrackTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final info = _resolveTrackInfo(trackId, ref);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: GestureDetector(
        onTap: onRemove,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFE53935),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.remove, color: Colors.white, size: 18),
        ),
      ),
      title: Row(
        children: [
          _Cover(url: info.coverUrl, size: 44),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
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
          ),
        ],
      ),
      trailing: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle, color: Colors.white38, size: 20),
      ),
    );
  }
}

// ── Suggestion tile (same-artist or history fill) ────────────────────────────

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.track, required this.onAdd});
  final HistoryTrack track;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white10,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.add, color: Colors.white54, size: 18),
        ),
      ),
      title: Row(
        children: [
          _Cover(url: track.coverUrl, size: 44),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  track.artist.name,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
