import 'package:flutter/material.dart';

import '../../../../core/design_system/colors.dart';

/// Seekable playback progress bar used on the full player screen (PlayerScreen).
///
/// Takes [positionSeconds] as a double for smooth sub-second animation
/// instead of jumping by 1-second intervals.
///
/// The bar correctly fills to 100% when the track finishes because
/// [positionSeconds] is set to [durationSeconds] exactly on completion.
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
    final activeWindow =
        (activeEnd - activeStart).clamp(1.0, durationSeconds == 0 ? 1.0 : durationSeconds.toDouble());

    // Clamp position into [activeStart, activeEnd] and compute 0–1 progress.
    final clampedPosition = positionSeconds.clamp(activeStart, activeEnd);
    final progress =
        ((clampedPosition - activeStart) / activeWindow).clamp(0.0, 1.0);

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
              // Background track
              Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Preview-only cap (lighter region showing max playable range)
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
              // Played portion — fills to 100% exactly when song ends
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Scrubber thumb
              FractionallySizedBox(
                widthFactor: progress,
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
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}