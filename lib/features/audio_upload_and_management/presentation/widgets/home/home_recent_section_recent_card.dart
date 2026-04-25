part of 'home_recent_section.dart';

/// Card that displays a track the user has actually listened to,
/// using data from their local listening history.
class _HistoryRecentCard extends StatelessWidget {
  const _HistoryRecentCard({
    required this.historyTrack,
    required this.onTap,
  });

  final HistoryTrack historyTrack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final coverUrl = historyTrack.coverUrl;
    final position = historyTrack.lastPositionSeconds;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF171717),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: coverUrl != null && coverUrl.isNotEmpty
                  ? Image.network(
                      coverUrl,
                      width: 72,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _artworkPlaceholder(),
                    )
                  : _artworkPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    historyTrack.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    historyTrack.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (position > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Resume ${_fmt(position)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _artworkPlaceholder() {
    return Container(
      width: 72,
      color: const Color(0xFF3A4A5A),
      child: const Center(
        child: Icon(
          Icons.music_note,
          color: Color(0xFF6A8AAA),
          size: 28,
        ),
      ),
    );
  }

  String _fmt(int totalSeconds) {
    final safe = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = safe ~/ 60;
    final seconds = (safe % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Card that displays a track from the user's uploads.
class _RecentCard extends ConsumerWidget {
  const _RecentCard({required this.item, required this.onTap});

  final UploadItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedItemAsync = ref.watch(trackDetailItemProvider(item));
    final resolvedItem = resolvedItemAsync.asData?.value ?? item;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF171717),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: UploadArtworkView(
                localPath: resolvedItem.localArtworkPath,
                remoteUrl: resolvedItem.artworkUrl,
                width: 72,
                height: double.infinity,
                backgroundColor: const Color(0xFF3A4A5A),
                placeholder: const Icon(
                  Icons.music_note,
                  color: Color(0xFF6A8AAA),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resolvedItem.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resolvedItem.artistDisplay,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
