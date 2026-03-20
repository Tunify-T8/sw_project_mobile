import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../providers/track_detail_waveform_provider.dart';

/// Renders the SoundCloud-style waveform exactly as seen in the screenshot:
///
///
/// Orange bars = played portion · White bars = unplayed portion
/// The entire component is display-only — no playback, pure visualisation.
class TrackDetailSoundcloudWaveform extends StatelessWidget {
  const TrackDetailSoundcloudWaveform({
    super.key,
    required this.state,
    required this.isLoading,
    this.bars,

    /// Progress fraction 0.0–1.0 of how far through the track we are.
    /// Default 0 = all bars white (unplayed), for display-only mode.
    this.progress = 0.0,
  });

  final TrackDetailWaveformState state;
  final List<double>? bars;
  final bool isLoading;
  final double progress;

  @override
  Widget build(BuildContext context) {
    // Total widget height. Upper bars occupy 54%, gap line ~2px, mirror 44%.
    const totalHeight = 220.0;

    return SizedBox(
      width: double.infinity,
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final waveformBars = bars;

          // ── Dynamic waveform generated from the audio file ─────────────
          if (waveformBars != null && waveformBars.isNotEmpty) {
            return _DynamicWaveform(
              bars: waveformBars,
              progress: progress,
              duration: state.duration,
              totalHeight: totalHeight,
              containerWidth: constraints.maxWidth,
            );
          }

          // ── Loading spinner while extraction is running ─────────────────
          if (isLoading) {
            return _LoadingPlaceholder(totalHeight: totalHeight);
          }

          // ── Fallback: network waveform image or skeleton bars ───────────
          return _FallbackWaveform(
            waveformUrl: state.waveformUrl,
            duration: state.duration,
            progress: progress,
            totalHeight: totalHeight,
            containerWidth: constraints.maxWidth,
          );
        },
      ),
    );
  }
}

// ── Dynamic waveform (real bars from audio_waveforms extraction) ──────────────

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
    // Time badge sits at the progress point, 20px above the centre line.
    const badgeWidth = 100.0;
    final maxLeft = math.max(0.0, containerWidth - badgeWidth);
    final badgeLeft = (maxLeft * progress).clamp(0.0, maxLeft);
    // Centre line Y = 54% down from top
    final centreY = totalHeight * 0.54;
    final badgeTop = centreY - 42.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Centre hairline ─────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          top: centreY,
          child: Container(height: 1.2, color: Colors.white),
        ),
        // ── Waveform bars (upper + mirrored lower) ──────────────────────
        Positioned.fill(
          child: CustomPaint(
            painter: _SCWaveformPainter(
              bars: bars,
              progress: progress,
              centreRatio: 0.54,
            ),
          ),
        ),
        // ── Time badge ──────────────────────────────────────────────────
        Positioned(
          left: badgeLeft,
          top: badgeTop,
          child: _TimeBadge(progress: progress, duration: duration),
        ),
      ],
    );
  }
}

// ── Fallback when no bars extracted yet ───────────────────────────────────────

class _FallbackWaveform extends StatelessWidget {
  const _FallbackWaveform({
    required this.waveformUrl,
    required this.duration,
    required this.progress,
    required this.totalHeight,
    required this.containerWidth,
  });

  final String? waveformUrl;
  final Duration duration;
  final double progress;
  final double totalHeight;
  final double containerWidth;

  @override
  Widget build(BuildContext context) {
    final centreY = totalHeight * 0.54;
    final badgeTop = centreY - 42.0;
    final trimmedWaveformUrl = waveformUrl?.trim();
    final hasWaveformImage =
        trimmedWaveformUrl != null && trimmedWaveformUrl.isNotEmpty;
    const badgeWidth = 100.0;
    final maxLeft = math.max(0.0, containerWidth - badgeWidth);
    final badgeLeft = (maxLeft * progress).clamp(0.0, maxLeft);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: centreY,
          child: Container(
            height: 1.2,
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        Positioned.fill(
          child: hasWaveformImage
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Image.network(
                    trimmedWaveformUrl,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, _, _) => CustomPaint(
                      painter: _SkeletonWaveformPainter(centreRatio: 0.54),
                    ),
                  ),
                )
              : CustomPaint(
                  painter: _SkeletonWaveformPainter(centreRatio: 0.54),
                ),
        ),
        // Time badge always visible even on fallback
        Positioned(
          left: badgeLeft,
          top: badgeTop,
          child: _TimeBadge(progress: progress, duration: duration),
        ),
      ],
    );
  }
}

// ── Loading placeholder ────────────────────────────────────────────────────────

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder({required this.totalHeight});
  final double totalHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // Faint skeleton so the space doesn't look empty
          Positioned.fill(
            child: CustomPaint(
              painter: _SkeletonWaveformPainter(
                centreRatio: 0.54,
                opacity: 0.22,
              ),
            ),
          ),
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Time badge ────────────────────────────────────────────────────────────────

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
        color: Colors.black.withValues(alpha: 0.88),
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

// ── Real waveform painter ─────────────────────────────────────────────────────
//
// Matches the SoundCloud screenshot:
//  • Bars grow UP and DOWN from centreY
//  • Upper half: full opacity  (played = orange, unplayed = white)
//  • Lower half: mirrored reflection at 35% opacity
//  • Bar width ≈2.5px, gap ≈1.5px, ~170 bars across full width
//  • Minimum visible bar height = 8px so even silent parts are visible

class _SCWaveformPainter extends CustomPainter {
  const _SCWaveformPainter({
    required this.bars,
    required this.progress,
    required this.centreRatio,
  });

  final List<double> bars;
  final double progress;
  final double centreRatio;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;

    final centreY = size.height * centreRatio;
    final upperZone = centreY; // pixels available above centre

    // Bar geometry — exactly like SoundCloud tight packing
    const gap = 1.6;
    final totalGap = gap * (bars.length - 1);
    final barWidth = math.max(
      1.5,
      math.min(3.2, (size.width - totalGap) / bars.length),
    );
    final stride = barWidth + gap;

    final playedCount = (bars.length * progress).round().clamp(0, bars.length);

    for (int i = 0; i < bars.length; i++) {
      final x = i * stride + barWidth / 2;
      final normalised = bars[i].clamp(0.08, 1.0).toDouble();

      // Upper bar: up to 88% of available upper zone
      final upperH = math.max(8.0, normalised * upperZone * 0.88);
      // Lower mirror: 55% of upper height
      final lowerH = math.max(4.0, upperH * 0.55);

      final isPlayed = i < playedCount;

      // ── Upper bar (full opacity) ────────────────────────────────────
      final upperPaint = Paint()
        ..color = isPlayed
            ? const Color(0xFFFF5500)
            : Colors.white.withValues(alpha: 0.95)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barWidth;

      canvas.drawLine(
        Offset(x, centreY - upperH),
        Offset(x, centreY - 1),
        upperPaint,
      );

      // ── Lower mirror (reduced opacity) ─────────────────────────────
      final lowerPaint = Paint()
        ..color = isPlayed
            ? const Color(0xFFFF5500).withValues(alpha: 0.32)
            : Colors.white.withValues(alpha: 0.32)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barWidth;

      canvas.drawLine(
        Offset(x, centreY + 1),
        Offset(x, centreY + lowerH),
        lowerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SCWaveformPainter old) =>
      old.bars != bars || old.progress != progress;
}

// ── Skeleton / placeholder painter ───────────────────────────────────────────
//
// Used while extraction is running and as fallback when no bars are available.
// Generates a naturalistic-looking wave using a combination of sine waves,
// so it doesn't look like a flat line or random noise.

class _SkeletonWaveformPainter extends CustomPainter {
  const _SkeletonWaveformPainter({
    required this.centreRatio,
    this.opacity = 0.45,
  });

  final double centreRatio;
  final double opacity;

  // Deterministic skeleton bars — looks like a real song waveform
  static List<double> _generateBars(int count) {
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
    const barCount = 150;
    final bars = _generateBars(barCount);

    final centreY = size.height * centreRatio;
    const gap = 1.6;
    final totalGap = gap * (barCount - 1);
    final barWidth = math.max(
      1.5,
      math.min(3.2, (size.width - totalGap) / barCount),
    );
    final stride = barWidth + gap;
    final upperZone = centreY;

    for (int i = 0; i < barCount; i++) {
      final x = i * stride + barWidth / 2;
      final normalised = bars[i];
      final upperH = math.max(8.0, normalised * upperZone * 0.88);
      final lowerH = math.max(4.0, upperH * 0.55);

      final upperPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barWidth;

      canvas.drawLine(
        Offset(x, centreY - upperH),
        Offset(x, centreY - 1),
        upperPaint,
      );

      final lowerPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.35)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barWidth;

      canvas.drawLine(
        Offset(x, centreY + 1),
        Offset(x, centreY + lowerH),
        lowerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SkeletonWaveformPainter old) =>
      old.centreRatio != centreRatio || old.opacity != opacity;
}
