import 'package:flutter/material.dart';

import '../../../../core/design_system/colors.dart';

/// Seekable playback bar.
///
/// The backend may return preview-only playback. In that case the seekable
/// window is limited to the preview segment.
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
  final int positionSeconds;
  final int durationSeconds;
  final bool isPreviewOnly;
  final int previewStartSeconds;
  final int previewDurationSeconds;
  final void Function(int positionSeconds) onSeek;

  @override
  Widget build(BuildContext context) {
    final activeStart = isPreviewOnly ? previewStartSeconds : 0;
    final activeEnd = isPreviewOnly
        ? previewStartSeconds + previewDurationSeconds
        : durationSeconds;
    final activeWindow = (activeEnd - activeStart).clamp(1, durationSeconds == 0 ? 1 : durationSeconds);
    final clampedPosition = positionSeconds.clamp(activeStart, activeEnd);
    final progress = ((clampedPosition - activeStart) / activeWindow)
        .clamp(0.0, 1.0)
        .toDouble();
    final previewCapFraction = durationSeconds > 0
        ? ((previewStartSeconds + previewDurationSeconds) / durationSeconds)
            .clamp(0.0, 1.0)
            .toDouble()
        : 0.0;

    int _mapLocalRatioToPosition(double ratio) {
      final relativePosition = (ratio * activeWindow).round();
      return activeStart + relativePosition;
    }

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        final ratio = (localPos.dx / box.size.width).clamp(0.0, 1.0).toDouble();
        onSeek(_mapLocalRatioToPosition(ratio));
      },
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        final ratio = (localPos.dx / box.size.width).clamp(0.0, 1.0).toDouble();
        onSeek(_mapLocalRatioToPosition(ratio));
      },
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
    );
  }
}
