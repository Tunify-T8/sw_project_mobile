import 'package:flutter/material.dart';

/// Seekable waveform / progress bar.
///
/// When [isPreviewOnly] is true, the bar is visually capped at [previewEndSeconds]
/// and the user cannot seek beyond it.
class PlayerWaveformBar extends StatelessWidget {
  const PlayerWaveformBar({
    super.key,
    required this.waveformUrl,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.onSeek,
    this.isPreviewOnly = false,
    this.previewEndSeconds = 30,
  });

  final String waveformUrl;
  final int positionSeconds;
  final int durationSeconds;
  final bool isPreviewOnly;
  final int previewEndSeconds;
  final void Function(int positionSeconds) onSeek;

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = isPreviewOnly ? previewEndSeconds : durationSeconds;
    final progress = effectiveDuration > 0
        ? (positionSeconds / effectiveDuration).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        final ratio = (localPos.dx / box.size.width).clamp(0.0, 1.0);
        final newPos = (ratio * effectiveDuration).round();
        onSeek(newPos);
      },
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        final ratio = (localPos.dx / box.size.width).clamp(0.0, 1.0);
        final newPos = (ratio * effectiveDuration).round();
        onSeek(newPos);
      },
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Track (background)
            Container(
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Preview cap line (if preview-only)
            if (isPreviewOnly && durationSeconds > 0)
              FractionallySizedBox(
                widthFactor: previewEndSeconds / durationSeconds,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

            // Played portion
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Thumb
            FractionallySizedBox(
              widthFactor: progress,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
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
