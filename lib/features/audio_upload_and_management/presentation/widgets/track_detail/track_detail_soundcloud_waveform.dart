import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../providers/track_detail_waveform_provider.dart';

class TrackDetailSoundcloudWaveform extends StatelessWidget {
  const TrackDetailSoundcloudWaveform({
    super.key,
    required this.state,
    required this.isLoading,
    this.bars,
    this.progress = 0.0,
  });

  final TrackDetailWaveformState state;
  final List<double>? bars;
  final bool isLoading;
  final double progress;

  @override
  Widget build(BuildContext context) {
    const totalHeight = 220.0;

    return SizedBox(
      width: double.infinity,
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final waveformBars = bars;
          if (waveformBars != null && waveformBars.isNotEmpty) {
            return _DynamicWaveform(
              bars: waveformBars,
              progress: progress,
              duration: state.duration,
              totalHeight: totalHeight,
              containerWidth: constraints.maxWidth,
            );
          }

          return _FallbackWaveform(
            duration: state.duration,
            progress: progress,
            totalHeight: totalHeight,
            containerWidth: constraints.maxWidth,
            useMutedOpacity: isLoading,
          );
        },
      ),
    );
  }
}

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
  })  : barCount = bars.length,
        safeProgress = progress.clamp(0.0, 1.0),
        viewportWidth = containerWidth,
        stride = _resolveStride(containerWidth),
        playheadAnchorX = containerWidth * 0.62,
        contentWidth = math.max(containerWidth, bars.length * _resolveStride(containerWidth)) {
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

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.progress, required this.duration});

  final double progress;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final played = Duration(
      milliseconds: (duration.inMilliseconds * progress).round(),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.88),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatTrackDetailDuration(played),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              width: 1,
              height: 13,
              margin: const EdgeInsets.symmetric(horizontal: 7),
              color: Colors.white24,
            ),
            Text(
              formatTrackDetailDuration(duration),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SCWaveformPainter extends CustomPainter {
  const _SCWaveformPainter({
    required this.bars,
    required this.progress,
    required this.centreRatio,
    required this.metrics,
  });

  final List<double> bars;
  final double progress;
  final double centreRatio;
  final _WaveformMetrics metrics;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;

    final centreY = size.height * centreRatio;
    final upperZone = centreY;
    final barWidth = math.max(1.8, metrics.stride * 0.64);
    final playedPaint = Paint()
      ..color = const Color(0xFFFF5A14)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;
    final unplayedPaint = Paint()
      ..color = Colors.white.withOpacity(0.94)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;
    final playedReflectionPaint = Paint()
      ..color = const Color(0xFFFFB187).withOpacity(0.88)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;
    final unplayedReflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.33)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    for (int i = 0; i < bars.length; i++) {
      final x = (i * metrics.stride + metrics.stride * 0.5) - metrics.scrollX;
      if (x < -barWidth || x > size.width + barWidth) continue;

      final normalised = bars[i].clamp(0.08, 1.0).toDouble();
      final upperH = math.max(12.0, normalised * upperZone * 0.50);
      final lowerH = math.max(9.0, upperH * 0.42);
      final isPlayed = x <= metrics.playheadX;

      canvas.drawLine(
        Offset(x, centreY - upperH),
        Offset(x, centreY - 1),
        isPlayed ? playedPaint : unplayedPaint,
      );
      canvas.drawLine(
        Offset(x, centreY + 2),
        Offset(x, centreY + lowerH),
        isPlayed ? playedReflectionPaint : unplayedReflectionPaint,
      );
    }

    final playheadPaint = Paint()..color = Colors.white.withOpacity(0.16);
    canvas.drawRect(
      Rect.fromLTWH(metrics.playheadX - 0.8, centreY - 92, 1.6, 144),
      playheadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SCWaveformPainter old) =>
      old.bars != bars ||
      (old.progress - progress).abs() > 0.001 ||
      old.metrics.scrollX != metrics.scrollX;
}

class _SkeletonWaveformPainter extends CustomPainter {
  const _SkeletonWaveformPainter({
    required this.centreRatio,
    required this.metrics,
    this.opacity = 0.45,
  });

  final double centreRatio;
  final _WaveformMetrics metrics;
  final double opacity;

  static List<double> generateBars(int count) {
    final result = <double>[];
    for (int i = 0; i < count; i++) {
      final t = i / count;
      final v =
          0.18 +
          0.50 * math.pow(math.sin(t * math.pi * 6.8).abs(), 0.6) +
          0.18 * math.pow(math.cos(t * math.pi * 14.2).abs(), 1.2) +
          0.12 * math.sin(t * math.pi * 31.4 + 0.7).abs();
      result.add(v.clamp(0.08, 1.0).toDouble());
    }
    return result;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bars = generateBars(180);
    final centreY = size.height * centreRatio;
    final upperZone = centreY;
    final barWidth = math.max(1.8, metrics.stride * 0.64);
    final upperPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;
    final lowerPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.38)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    for (int i = 0; i < bars.length; i++) {
      final x = (i * metrics.stride + metrics.stride * 0.5) - metrics.scrollX;
      if (x < -barWidth || x > size.width + barWidth) continue;
      final normalised = bars[i];
      final upperH = math.max(12.0, normalised * upperZone * 0.50);
      final lowerH = math.max(9.0, upperH * 0.42);

      canvas.drawLine(Offset(x, centreY - upperH), Offset(x, centreY - 1), upperPaint);
      canvas.drawLine(Offset(x, centreY + 2), Offset(x, centreY + lowerH), lowerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SkeletonWaveformPainter old) =>
      old.centreRatio != centreRatio ||
      old.opacity != opacity ||
      old.metrics.scrollX != metrics.scrollX;
}
