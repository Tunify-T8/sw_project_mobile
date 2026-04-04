import 'package:flutter/material.dart';

import '../../../../core/design_system/colors.dart';

/// Seekable playback progress bar used on the full player screen (PlayerScreen).
///
/// Takes [positionSeconds] as a double for smooth sub-second animation
/// instead of jumping by 1-second intervals.
///
/// Uses [TweenAnimationBuilder] internally so the bar animates smoothly
/// between the ≈7 state updates per second produced by the position stream,
/// matching the same pattern used by the mini-player ring button.
///
/// The bar fills to exactly 100% when the track finishes because of the
/// near-end guard: once [positionSeconds] is within 0.25 s of [activeEnd]
/// the progress is pinned to 1.0.
class PlayerWaveformBar extends StatelessWidget {
  const PlayerWaveformBar({
    super.key,
    required this.waveformUrl,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.onSeek,
    this.isPreviewOnly = false,
    this.previewStartSeconds = 0,
    this.previewDurationSeconds = 30,
  });

  final String waveformUrl;

  /// Current playback position in seconds. Accepts fractional values for smooth
  /// animation — pass [PlayerState.positionSeconds] directly (no .round()).
  final double positionSeconds;
  final int durationSeconds;
  final bool isPreviewOnly;
  final int previewStartSeconds;
  final int previewDurationSeconds;
  final void Function(int positionSeconds) onSeek;

  @override
  Widget build(BuildContext context) {
    final activeStart = isPreviewOnly ? previewStartSeconds.toDouble() : 0.0;
    final activeEnd = isPreviewOnly
        ? (previewStartSeconds + previewDurationSeconds).toDouble()
        : durationSeconds.toDouble();
    final activeWindow = (activeEnd - activeStart)
        .clamp(1.0, durationSeconds == 0 ? 1.0 : durationSeconds.toDouble());

    // Near-end guard: pin to 1.0 within 0.25 s of the end so the bar always
    // reaches 100% even if the final position event fires slightly early.
    final clampedPosition = positionSeconds.clamp(activeStart, activeEnd);
    final double progress = positionSeconds >= activeEnd - 0.25
        ? 1.0
        : ((clampedPosition - activeStart) / activeWindow).clamp(0.0, 1.0);

    final previewCapFraction = durationSeconds > 0
        ? ((previewStartSeconds + previewDurationSeconds) / durationSeconds)
            .clamp(0.0, 1.0)
            .toDouble()
        : 0.0;

    int mapLocalRatioToPosition(double ratio) {
      final relativePosition = (ratio * activeWindow).round();
      return activeStart.round() + relativePosition;
    }

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localPos = box.globalToLocal(details.globalPosition);
        final ratio = (localPos.dx / box.size.width).clamp(0.0, 1.0);
        onSeek(mapLocalRatioToPosition(ratio));
      },
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localPos = box.globalToLocal(details.globalPosition);
        final ratio = (localPos.dx / box.size.width).clamp(0.0, 1.0);
        onSeek(mapLocalRatioToPosition(ratio));
      },
      child: SizedBox(
        height: 44,
        child: RepaintBoundary(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background track — never changes, stays outside the tween.
              Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Preview-only cap (lighter region showing max playable range).
              if (isPreviewOnly && durationSeconds > 0)
                FractionallySizedBox(
                  widthFactor: previewCapFraction,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              // Animated progress bar + scrubber thumb.
              // Uses TweenAnimationBuilder so the bar glides smoothly between
              // the ≈7 position-state updates per second, giving the impression
              // of continuous 60 fps movement without the cost of 33 rebuilds/s.
              // ValueKey on durationSeconds resets the animation on track change.
              TweenAnimationBuilder<double>(
                key: ValueKey(durationSeconds),
                tween: Tween<double>(end: progress),
                duration: const Duration(milliseconds: 180),
                curve: Curves.linear,
                builder: (context, anim, _) {
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Played portion — fills to 100% exactly when song ends.
                      FractionallySizedBox(
                        widthFactor: anim,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Scrubber thumb.
                      FractionallySizedBox(
                        widthFactor: anim,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
