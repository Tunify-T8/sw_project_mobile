import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/design_system/colors.dart';
import '../../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../domain/entities/upload_item.dart';
import '../../providers/track_detail_waveform_provider.dart';
import 'track_detail_soundcloud_waveform.dart';

class TrackDetailWaveformPanel extends ConsumerWidget {
  const TrackDetailWaveformPanel({
    super.key,
    required this.item,
    required this.state,
    required this.onMoreTap,
    required this.onPlayPauseTap,
    required this.onSeekFraction,
  });

  final UploadItem item;
  final TrackDetailWaveformState state;
  final VoidCallback onMoreTap;
  final VoidCallback onPlayPauseTap;
  final ValueChanged<double> onSeekFraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waveformBarsAsync = ref.watch(trackDetailWaveformBarsProvider(item));
    final bars = item.waveformBars ?? waveformBarsAsync.asData?.value;
    final description = item.description?.trim() ?? '';
    final playerState = ref.watch(playerProvider).asData?.value;
    final isCurrentTrack = playerState?.bundle?.trackId == item.id;
    final isPlaying = isCurrentTrack && playerState?.isPlaying == true;
    final progress = isCurrentTrack && item.durationSeconds > 0
        ? ((playerState?.positionSeconds ?? 0) / item.durationSeconds)
            .clamp(0.0, 1.0)
            .toDouble()
        : 0.0;

    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              if (description.isNotEmpty && isPlaying) ...[
                Align(
                  alignment: Alignment.center,
                  child: _WaveformCommentBubble(text: description),
                ),
                const SizedBox(height: 14),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                child: isPlaying
                    ? _PlayingWaveform(
                        key: const ValueKey('playing'),
                        item: item,
                        state: state,
                        bars: bars,
                        isLoading: item.waveformBars == null && waveformBarsAsync.isLoading,
                        progress: progress,
                        onSeekFraction: onSeekFraction,
                      )
                    : _PausedSurface(
                        key: const ValueKey('paused'),
                        item: item,
                        progress: progress,
                        onPlayPauseTap: onPlayPauseTap,
                        onSeekFraction: onSeekFraction,
                      ),
              ),
              const SizedBox(height: 16),
              const _CommentComposerBar(),
              const SizedBox(height: 16),
              _BottomActionBar(onMoreTap: onMoreTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayingWaveform extends StatelessWidget {
  const _PlayingWaveform({
    super.key,
    required this.item,
    required this.state,
    required this.bars,
    required this.isLoading,
    required this.progress,
    required this.onSeekFraction,
  });

  final UploadItem item;
  final TrackDetailWaveformState state;
  final List<double>? bars;
  final bool isLoading;
  final double progress;
  final ValueChanged<double> onSeekFraction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _seekFromTap(details, context),
      onHorizontalDragUpdate: (details) => _seekFromDrag(details, context),
      child: SizedBox(
        key: const ValueKey('waveform'),
        height: 250,
        child: TrackDetailSoundcloudWaveform(
          state: state,
          bars: bars,
          isLoading: isLoading,
          progress: progress,
        ),
      ),
    );
  }

  void _seekFromTap(TapDownDetails details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    onSeekFraction((local.dx / box.size.width).clamp(0.0, 1.0));
  }

  void _seekFromDrag(DragUpdateDetails details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    onSeekFraction((local.dx / box.size.width).clamp(0.0, 1.0));
  }
}

class _PausedSurface extends ConsumerWidget {
  const _PausedSurface({
    super.key,
    required this.item,
    required this.progress,
    required this.onPlayPauseTap,
    required this.onSeekFraction,
  });

  final UploadItem item;
  final double progress;
  final VoidCallback onPlayPauseTap;
  final ValueChanged<double> onSeekFraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      key: const ValueKey('paused-surface'),
      height: 250,
      child: Column(
        children: [
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PauseCircleButton(
                icon: Icons.skip_previous_rounded,
                onTap: () => ref.read(playerProvider.notifier).previous(),
              ),
              _PauseCircleButton(
                icon: Icons.play_arrow_rounded,
                size: 98,
                iconSize: 54,
                onTap: onPlayPauseTap,
              ),
              _PauseCircleButton(
                icon: Icons.skip_next_rounded,
                onTap: () => ref.read(playerProvider.notifier).next(),
              ),
            ],
          ),
          const SizedBox(height: 46),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _seekFromTap(details, context),
            onHorizontalDragUpdate: (details) => _seekFromDrag(details, context),
            child: Column(
              children: [
                Text(
                  '${_fmt(progress, item.durationSeconds)} | ${_fmt(1, item.durationSeconds)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 3,
                    child: Stack(
                      children: [
                        Container(color: Colors.black.withOpacity(0.34)),
                        FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _seekFromTap(TapDownDetails details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    onSeekFraction((local.dx / box.size.width).clamp(0.0, 1.0));
  }

  void _seekFromDrag(DragUpdateDetails details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    onSeekFraction((local.dx / box.size.width).clamp(0.0, 1.0));
  }

  String _fmt(double progress, int durationSeconds) {
    final value = (durationSeconds * progress.clamp(0.0, 1.0)).round();
    final minutes = value ~/ 60;
    final seconds = (value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _PauseCircleButton extends StatelessWidget {
  const _PauseCircleButton({
    required this.icon,
    required this.onTap,
    this.size = 74,
    this.iconSize = 42,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.82),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}

class _WaveformCommentBubble extends StatelessWidget {
  const _WaveformCommentBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white70, size: 18),
        ),
        const SizedBox(width: 10),
        Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade600.withOpacity(0.72),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentComposerBar extends StatelessWidget {
  const _CommentComposerBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade700.withOpacity(0.68),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Comment...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Text('🔥', style: TextStyle(fontSize: 28)),
          SizedBox(width: 14),
          Text('👏', style: TextStyle(fontSize: 28)),
          SizedBox(width: 14),
          Text('🥺', style: TextStyle(fontSize: 28)),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.onMoreTap});

  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _ActionMetric(icon: Icons.favorite_border, label: '36K'),
          const _ActionMetric(icon: Icons.chat_bubble_outline, label: '191'),
          const _ActionMetric(icon: Icons.ios_share_outlined, label: ''),
          const _ActionMetric(icon: Icons.playlist_play, label: ''),
          _ActionMetric(icon: Icons.more_horiz, label: '', onTap: onMoreTap),
        ],
      ),
    );
  }
}

class _ActionMetric extends StatelessWidget {
  const _ActionMetric({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 29),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
