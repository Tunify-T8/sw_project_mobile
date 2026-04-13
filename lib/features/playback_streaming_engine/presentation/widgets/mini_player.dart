import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../../audio_upload_and_management/presentation/utils/upload_player_launcher.dart';
import '../../../engagements_social_interactions/presentation/widgets/like_button.dart'; // engagement addition
import '../providers/player_provider.dart';

part 'mini_player_ring_button.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider);
    final playerState = playerAsync.asData?.value;

    if (playerState == null || playerState.bundle == null) {
      return const SizedBox.shrink();
    }

    final bundle = playerState.bundle!;
    final progress = playerState.normalizedProgress;

    return Padding(
      // Smaller outer padding for a more compact footprint.
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) async {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -220) {
            await ref.read(playerProvider.notifier).next();
          } else if (velocity > 220) {
            await ref.read(playerProvider.notifier).previous();
          }
        },
        child: Container(
          // Height reduced from 88 → 68 and corner radius adjusted to match.
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF242424), Color(0xFF323232), Color(0xFF232323)],
            ),
            border: Border.all(color: Colors.white10, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Tighter left gutter to match the smaller bar.
              const SizedBox(width: 10),
              _RingPlayButton(
                progress: progress,
                isPlaying: playerState.isPlaying,
                onTap: () async {
                  if (playerState.isPlaying) {
                    await ref.read(playerProvider.notifier).pause();
                  } else {
                    await ref.read(playerProvider.notifier).play();
                  }
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => openCurrentPlaybackTrackSurface(context, ref),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Column(
                      key: ValueKey(bundle.trackId),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bundle.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // Slightly smaller to suit the compact bar.
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bundle.artist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.devices_outlined),
                color: Colors.white70,
                tooltip: 'Open track details',
              ),
              LikeButton(trackId: bundle.trackId, showCount: false), // engagement addition
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}