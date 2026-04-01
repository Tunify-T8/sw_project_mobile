part of 'library_screen.dart';

class _LibraryHistoryTile extends ConsumerWidget {
  const _LibraryHistoryTile({required this.track, required this.queueTracks});

  final HistoryTrack track;
  final List<HistoryTrack> queueTracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(globalTrackStoreProvider);
    final stored = storedUploadItemForTrack(store, track.trackId);
    final isBlocked = track.status == PlaybackStatus.blocked;

    return InkWell(
      onTap: isBlocked
          ? null
          : () async {
              final trackIds = queueTracks
                  .map((item) => item.trackId)
                  .toList(growable: false);
              final currentIndex = trackIds.indexOf(track.trackId);

              if (stored != null) {
                final queueItems = queueTracks
                    .map(
                      (item) => storedUploadItemForTrack(store, item.trackId),
                    )
                    .whereType<UploadItem>()
                    .toList(growable: false);
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
            },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 58,
                height: 58,
                color: const Color(0xFF202020),
                child: (track.coverUrl?.isNotEmpty == true)
                    ? Image.network(
                        track.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stackTrace) =>
                            _placeholder(isBlocked),
                      )
                    : _placeholder(isBlocked),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isBlocked ? Colors.white38 : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'â–¶ ${_formatPlayCount(track.playCount)} Â· ${_fmt(track.durationSeconds)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.more_horiz, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(bool isBlocked) {
    return Center(
      child: Icon(
        isBlocked ? Icons.lock : Icons.music_note,
        color: isBlocked ? Colors.redAccent.withOpacity(0.6) : Colors.white24,
      ),
    );
  }

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  String _formatPlayCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }
}
