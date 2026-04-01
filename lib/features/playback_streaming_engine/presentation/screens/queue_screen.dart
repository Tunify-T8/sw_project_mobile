import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../providers/player_provider.dart';
import '../widgets/mini_player.dart';

/// Queue / "Next up" screen — shown when user taps Queue from the player.
/// Matches the SoundCloud "Next up" sheet with draggable reordering.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider);
    final playerState = playerAsync.asData?.value;
    final queue = playerState?.queue;
    final bundle = playerState?.bundle;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      bottomNavigationBar: const MiniPlayer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Next up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle, color: Colors.white54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white54),
            onPressed: () {},
          ),
        ],
      ),
      body: queue == null || queue.trackIds.isEmpty
          ? _EmptyQueue(
              currentTitle: bundle?.title,
              currentArtist: bundle?.artist.name,
              currentCover: bundle?.coverUrl,
            )
          : _QueueList(
              playerState: playerState!,
              onTrackTap: (index) =>
                  ref.read(playerProvider.notifier).jumpToQueueIndex(index),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Queue list
// ---------------------------------------------------------------------------

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
        // Now playing header
        if (playerState.bundle != null)
          _NowPlayingRow(bundle: playerState.bundle!),

        // Divider
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

        // Queue tracks (items after current)
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
          // Artwork
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
                child: const Icon(Icons.music_note,
                    color: Colors.white24, size: 20),
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
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  bundle.artist?.name ?? '',
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 48,
          height: 48,
          color: const Color(0xFF2A2A2A),
          child: Center(
            child: Text(
              '${position + 1}',
              style:
                  const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
        ),
      ),
      title: Text(
        'Track $trackId',
        style:
            const TextStyle(color: Colors.white, fontSize: 14),
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
