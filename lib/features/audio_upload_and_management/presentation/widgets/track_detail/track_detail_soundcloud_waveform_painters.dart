part of 'track_detail_soundcloud_waveform.dart';

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

      canvas.drawLine(
        Offset(x, centreY - upperH),
        Offset(x, centreY - 1),
        upperPaint,
      );
      canvas.drawLine(
        Offset(x, centreY + 2),
        Offset(x, centreY + lowerH),
        lowerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SkeletonWaveformPainter old) =>
      old.centreRatio != centreRatio ||
      old.opacity != opacity ||
      old.metrics.scrollX != metrics.scrollX;
}
