import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';
import '../screens/player_screen.dart';

/// Persistent mini player bar that sits above the bottom nav bar.
/// Shows only when a track is loaded. Tapping opens [PlayerScreen].
///
/// Add this to your scaffold body or stack above the bottom nav:
/// ```dart
/// bottomNavigationBar: Column(
///   mainAxisSize: MainAxisSize.min,
///   children: [
///     const MiniPlayer(),
///     BottomNavigationBar(...),
///   ],
/// ),
/// ```
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider);

    // asData?.value works across all Riverpod 2.x (unlike valueOrNull which needs 2.4+)
    final playerState = playerAsync.asData?.value;

    // Hide when no track loaded or still in initial loading
    if (playerState == null || playerState.bundle == null) {
      return const SizedBox.shrink();
    }

    final bundle = playerState.bundle!;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PlayerScreen()),
        );
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),

            // Artwork thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                bundle.coverUrl,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 42,
                  height: 42,
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white30,
                    size: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Title + artist
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bundle.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    bundle.artist.name,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Play / pause button
            _MiniPlayerButton(
              isPlaying: playerState.isPlaying,
              isLoading: playerAsync.isLoading,
              onPlay: () => ref.read(playerProvider.notifier).play(),
              onPause: () => ref.read(playerProvider.notifier).pause(),
            ),

            // Next button
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white70),
              onPressed: playerState.queue != null
                  ? () => ref.read(playerProvider.notifier).next()
                  : null,
            ),

            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayerButton extends StatelessWidget {
  const _MiniPlayerButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onPlay,
    required this.onPause,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlay;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.orange,
          ),
        ),
      );
    }
    return IconButton(
      icon: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: 28,
      ),
      onPressed: isPlaying ? onPause : onPlay,
    );
  }
}