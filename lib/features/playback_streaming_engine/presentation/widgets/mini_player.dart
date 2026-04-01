import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../../audio_upload_and_management/presentation/utils/upload_player_launcher.dart';
import '../providers/player_provider.dart';

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
    final maxProgress = playerState.isPreviewOnly
        ? playerState.previewEndSeconds.toDouble()
        : bundle.durationSeconds.toDouble();
    final progress = maxProgress > 0
        ? (playerState.positionSeconds / maxProgress).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
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
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF242424),
                Color(0xFF323232),
                Color(0xFF232323),
              ],
            ),
            border: Border.all(color: Colors.white10, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.26),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
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
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => openCurrentPlaybackTrackSurface(context, ref),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bundle.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bundle.artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.devices_outlined),
                color: Colors.white70,
                tooltip: 'Open track details',
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  bundle.engagement.isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                color: bundle.engagement.isLiked
                    ? AppColors.primary
                    : Colors.white70,
                tooltip: 'Like',
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPlayButton extends StatelessWidget {
  const _RingPlayButton({
    required this.progress,
    required this.isPlaying,
    required this.onTap,
  });

  final double progress;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 62,
        height: 62,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 62,
              height: 62,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: progress),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: 3.6,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  );
                },
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 140),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey(isPlaying),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
