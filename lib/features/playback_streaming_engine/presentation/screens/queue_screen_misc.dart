part of 'queue_screen.dart';

class _QueueTrackTile extends StatelessWidget {
  const _QueueTrackTile({
    required this.trackId,
    required this.position,
    required this.onTap,
  });

  final String trackId;
  final int position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 48,
          height: 48,
          color: const Color(0xFF2A2A2A),
          child: Center(
            child: Text(
              '${position + 1}',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
        ),
      ),
      title: Text(
        'Track $trackId',
        style: const TextStyle(color: Colors.white, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: const Text(
        'Artist Name',
        style: TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: const Icon(Icons.drag_handle, color: Colors.white38),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue({this.currentTitle, this.currentArtist, this.currentCover});

  final String? currentTitle;
  final String? currentArtist;
  final String? currentCover;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.queue_music, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Queue is empty',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add tracks to build your queue',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
