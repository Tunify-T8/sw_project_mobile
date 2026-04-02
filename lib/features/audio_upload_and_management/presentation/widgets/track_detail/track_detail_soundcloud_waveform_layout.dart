part of 'track_detail_soundcloud_waveform.dart';

class _DynamicWaveform extends StatelessWidget {
  const _DynamicWaveform({
    required this.bars,
    required this.progress,
    required this.duration,
    required this.totalHeight,
    required this.containerWidth,
  });

  final List<double> bars;
  final double progress;
  final Duration duration;
  final double totalHeight;
  final double containerWidth;

  @override
  Widget build(BuildContext context) {
    final metrics = _WaveformMetrics(
      bars: bars,
      progress: progress,
      containerWidth: containerWidth,
    );
    final centreY = totalHeight * 0.56;
    final badgeTop = centreY - 40;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: centreY,
          child: Container(height: 1.0, color: Colors.white.withOpacity(0.34)),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _SCWaveformPainter(
                bars: bars,
                progress: progress,
                centreRatio: 0.56,
                metrics: metrics,
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          left: metrics.badgeLeft,
          top: badgeTop,
          child: _TimeBadge(progress: progress, duration: duration),
        ),
      ],
    );
  }
}

class _FallbackWaveform extends StatelessWidget {
  const _FallbackWaveform({
    required this.duration,
    required this.progress,
    required this.totalHeight,
    required this.containerWidth,
    required this.useMutedOpacity,
  });

  final Duration duration;
  final double progress;
  final double totalHeight;
  final double containerWidth;
  final bool useMutedOpacity;

  @override
  Widget build(BuildContext context) {
    final bars = _SkeletonWaveformPainter.generateBars(180);
    final metrics = _WaveformMetrics(
      bars: bars,
      progress: progress,
      containerWidth: containerWidth,
    );
    final centreY = totalHeight * 0.56;
    final badgeTop = centreY - 40;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: centreY,
          child: Container(height: 1.0, color: Colors.white.withOpacity(0.18)),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _SkeletonWaveformPainter(
                centreRatio: 0.56,
                metrics: metrics,
                opacity: useMutedOpacity ? 0.28 : 0.42,
              ),
            ),
          ),
        ),
        Positioned(
          left: metrics.badgeLeft,
          top: badgeTop,
          child: _TimeBadge(progress: progress, duration: duration),
        ),
      ],
    );
  }
}

class _WaveformMetrics {
  _WaveformMetrics({
    required List<double> bars,
    required double progress,
    required double containerWidth,
  }) : barCount = bars.length,
       safeProgress = progress.clamp(0.0, 1.0),
       viewportWidth = containerWidth,
       stride = _resolveStride(containerWidth),
       playheadAnchorX = containerWidth * 0.62,
       contentWidth = math.max(
         containerWidth,
         bars.length * _resolveStride(containerWidth),
       ) {
    final currentIndexDouble = safeProgress * math.max(0, barCount - 1);
    currentBarX = currentIndexDouble * stride + (stride * 0.5);
    final maxScroll = math.max(0.0, contentWidth - viewportWidth);
    scrollX = (currentBarX - playheadAnchorX).clamp(0.0, maxScroll);
    playheadX = (currentBarX - scrollX).clamp(0.0, viewportWidth);
    badgeLeft = (playheadX - 52).clamp(0.0, math.max(0.0, viewportWidth - 104));
  }

  final int barCount;
  final double safeProgress;
  final double viewportWidth;
  final double stride;
  final double playheadAnchorX;
  final double contentWidth;
  late final double currentBarX;
  late final double scrollX;
  late final double playheadX;
  late final double badgeLeft;

  static double _resolveStride(double width) {
    final density = width > 420 ? 3.45 : 3.15;
    return density;
  }
}
