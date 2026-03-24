// Upload Feature Guide:
// Purpose: Track detail widget used to build TrackDetailScreen.
// Used by: Referenced by nearby upload feature files.
// Concerns: Track visibility; Waveform generation.
import 'package:flutter/material.dart';

class TrackDetailMockWaveform extends StatelessWidget {
  const TrackDetailMockWaveform({
    super.key,
    this.rightAligned = false,
    this.height = 100,
  });

  static const _bars = [
    0.2,
    0.4,
    0.7,
    0.5,
    0.3,
    0.8,
    0.6,
    0.4,
    0.2,
    0.5,
    0.7,
    0.3,
    0.6,
    0.4,
    0.8,
    0.5,
    0.2,
    0.7,
    0.4,
    0.3,
    0.6,
    0.8,
    0.5,
    0.2,
    0.4,
    0.7,
    0.3,
    0.6,
    0.5,
    0.4,
    0.8,
    0.2,
    0.5,
    0.7,
    0.3,
    0.4,
    0.6,
    0.5,
    0.2,
    0.8,
  ];

  final bool rightAligned;
  final double height;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: height,
      child: CustomPaint(
        painter: _WaveformPainter(bars: _bars, progress: 0.08),
        size: Size(MediaQuery.of(context).size.width - 32, height),
      ),
    );

    if (rightAligned) {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(width: 260, child: content),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(height: height, child: content),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.bars, required this.progress});

  final List<double> bars;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final playedPaint = Paint()
      ..color = const Color(0xFFFF5500)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    final unplayedPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    final barWidth = size.width / bars.length;

    for (var index = 0; index < bars.length; index++) {
      final x = index * barWidth + barWidth / 2;
      final height = bars[index] * size.height * 0.85;
      final top = (size.height - height) / 2;
      final paint = (index / bars.length) < progress
          ? playedPaint
          : unplayedPaint;
      canvas.drawLine(Offset(x, top), Offset(x, top + height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
