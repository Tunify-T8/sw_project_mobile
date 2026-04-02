import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../providers/player_provider.dart';
import '../widgets/mini_player.dart';

part 'queue_screen_list.dart';
part 'queue_screen_misc.dart';

/// Queue / "Next up" screen â€” shown when user taps Queue from the player.
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
