import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../domain/entities/history_track.dart';
import '../../domain/entities/playback_status.dart';
import '../../domain/entities/playback_queue.dart';
import '../../domain/entities/player_seed_track.dart';
import '../providers/listening_history_provider.dart';
import '../providers/player_provider.dart';
import '../providers/player_repository_provider.dart';
import '../widgets/mini_player.dart';
import '../widgets/track_options_sheet.dart';

part 'queue_screen_list.dart';
part 'queue_screen_misc.dart';

/// Queue / "Next up" screen — shown when user taps Queue from the player.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider);
    final playerState = playerAsync.asData?.value;
    final queue = playerState?.queue;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      bottomNavigationBar: const MiniPlayer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Next Up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle, size: 22),
            color: (queue?.shuffle == true)
                ? AppColors.primary
                : Colors.white54,
            onPressed: playerState?.queue != null
                ? () => ref.read(playerProvider.notifier).toggleShuffle()
                : null,
          ),
          IconButton(
            icon: Icon(
              queue?.repeat == RepeatMode.one ? Icons.repeat_one : Icons.repeat,
              size: 22,
            ),
            color: (queue != null && queue.repeat != RepeatMode.none)
                ? AppColors.primary
                : Colors.white54,
            onPressed: playerState?.queue != null
                ? () => ref.read(playerProvider.notifier).toggleRepeat()
                : null,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _QueueBody(playerState: playerState),
    );
  }
}
