part of 'track_detail_waveform_panel.dart';

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
    required this.durationSeconds,
    required this.onPlayPauseTap,
    required this.onSeekFraction,
  });

  final UploadItem item;
  final double progress;
  final int durationSeconds;
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
            onHorizontalDragUpdate: (details) =>
                _seekFromDrag(details, context),
            child: Column(
              children: [
                Text(
                  '${_fmt(progress, durationSeconds)} | ${_fmt(1, durationSeconds)}',
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
