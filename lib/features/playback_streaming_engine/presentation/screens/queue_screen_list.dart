part of 'queue_screen.dart';

class _QueueList extends StatelessWidget {
  const _QueueList({required this.playerState, required this.onTrackTap});

  final PlayerState playerState;
  final ValueChanged<int> onTrackTap;

  @override
  Widget build(BuildContext context) {
    final queue = playerState.queue!;
    final currentIndex = queue.currentIndex;
    final trackIds = queue.trackIds;

    return Column(
      children: [
        if (playerState.bundle != null)
          _NowPlayingRow(bundle: playerState.bundle!),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'UP NEXT',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: trackIds.length - currentIndex - 1,
            itemBuilder: (context, i) {
              final trackIndex = currentIndex + 1 + i;
              return _QueueTrackTile(
                trackId: trackIds[trackIndex],
                position: trackIndex,
                onTap: () => onTrackTap(trackIndex),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NowPlayingRow extends StatelessWidget {
  const _NowPlayingRow({required this.bundle});

  final dynamic bundle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              bundle.coverUrl ?? '',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 48,
                height: 48,
                color: const Color(0xFF2A2A2A),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white24,
                  size: 20,
                ),
              ),
            ),
          ),
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
                  bundle.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  bundle.artist?.name ?? '',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.drag_handle, color: Colors.white38),
        ],
      ),
    );
  }
}
