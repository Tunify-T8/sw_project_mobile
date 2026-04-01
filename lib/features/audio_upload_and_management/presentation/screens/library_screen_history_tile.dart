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

    return GestureDetector(
      onTap: isBlocked
          ? null
          : () async {
              final trackIds = queueTracks
                  .map((item) => item.trackId)
                  .toList(growable: false);
              final currentIndex = trackIds.indexOf(track.trackId);

              await ref.read(playerProvider.notifier).loadTrackWithQueue(
                    trackId: track.trackId,
                    trackIds: trackIds,
                    currentIndex: currentIndex < 0 ? 0 : currentIndex,
                    autoPlay: true,
                    seedTrack: stored == null
                        ? null
                        : PlayerSeedTrack(
                            trackId: stored.id,
                            title: stored.title,
                            artistName: stored.artistDisplay,
                            durationSeconds: stored.durationSeconds,
                            coverUrl: stored.artworkUrl,
                            waveformUrl: stored.waveformUrl,
                            directAudioUrl: stored.audioUrl,
                            localFilePath: stored.localFilePath,
                          ),
                  );
              if (!context.mounted) return;
              await openCurrentPlaybackTrackSurface(context, ref);
            },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 64,
                height: 64,
                color: const Color(0xFF96B7FF),
                child: (track.coverUrl?.isNotEmpty == true)
                    ? Image.network(
                        track.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(isBlocked),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDuration(track.durationSeconds),
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.more_horiz, color: Colors.white54, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(bool isBlocked) {
    return Center(
      child: Icon(
        isBlocked ? Icons.lock : Icons.account_circle_rounded,
        color: isBlocked
            ? Colors.redAccent.withOpacity(0.6)
            : const Color(0xFF4872D7),
        size: 52,
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }
}
