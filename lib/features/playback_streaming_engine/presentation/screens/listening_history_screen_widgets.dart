part of 'listening_history_screen.dart';

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: Colors.white24, size: 72),
          SizedBox(height: 20),
          Text(
            'No listening history',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tracks you play will appear here',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _HistoryTrackTile extends StatelessWidget {
  const _HistoryTrackTile({required this.track, required this.onTap});

  final HistoryTrack track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBlocked = track.status == PlaybackStatus.blocked;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isBlocked ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
                    'â–¶ ${_formatPlayCount(track.playCount)} Â· ${_fmtDuration(track.durationSeconds)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
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

  String _fmtDuration(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

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
