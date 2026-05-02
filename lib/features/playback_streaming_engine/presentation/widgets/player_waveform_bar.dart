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
class PlayerWaveformBar extends StatefulWidget {
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

  /// Commits a seek. Receives a fractional second so the audio player lands on
  /// the exact pixel the user dragged to instead of snapping to a whole second.
  /// Fired on tap-down and drag-end only; drag-update is handled locally so
  /// the audio player isn't spammed with seeks (each one stalls the buffer).
  final void Function(double positionSeconds) onSeek;

  @override
  State<PlayerWaveformBar> createState() => _PlayerWaveformBarState();
}

class _PlayerWaveformBarState extends State<PlayerWaveformBar> {
  /// Non-null while the user is actively scrubbing. Overrides the position
  /// stream so the thumb tracks the finger 1:1 instead of fighting the audio
  /// player's lagging position events.
  double? _scrubSeconds;

  @override
  Widget build(BuildContext context) {
    final activeStart = widget.isPreviewOnly
        ? widget.previewStartSeconds.toDouble()
        : 0.0;
    final activeEnd = widget.isPreviewOnly
        ? (widget.previewStartSeconds + widget.previewDurationSeconds)
              .toDouble()
        : widget.durationSeconds.toDouble();
    final activeWindow = (activeEnd - activeStart).clamp(
      1.0,
      widget.durationSeconds == 0 ? 1.0 : widget.durationSeconds.toDouble(),
    );

    final renderedPosition = _scrubSeconds ?? widget.positionSeconds;

    // Near-end guard: pin to 1.0 within 0.25 s of the end so the bar always
    // reaches 100% even if the final position event fires slightly early.
    final clampedPosition = renderedPosition.clamp(activeStart, activeEnd);
    final double progress = renderedPosition >= activeEnd - 0.25
        ? 1.0
        : ((clampedPosition - activeStart) / activeWindow).clamp(0.0, 1.0);

    final previewCapFraction = widget.durationSeconds > 0
        ? ((widget.previewStartSeconds + widget.previewDurationSeconds) /
                  widget.durationSeconds)
              .clamp(0.0, 1.0)
              .toDouble()
        : 0.0;

    double mapLocalRatioToSeconds(double ratio) {
      return activeStart + ratio * activeWindow;
    }

    double ratioFromGlobal(Offset globalPosition) {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || box.size.width <= 0) return 0.0;
      final localPos = box.globalToLocal(globalPosition);
      return (localPos.dx / box.size.width).clamp(0.0, 1.0);
    }

    return GestureDetector(
      onHorizontalDragStart: (details) {
        final ratio = ratioFromGlobal(details.globalPosition);
        setState(() => _scrubSeconds = mapLocalRatioToSeconds(ratio));
      },
      onHorizontalDragUpdate: (details) {
        final ratio = ratioFromGlobal(details.globalPosition);
        setState(() => _scrubSeconds = mapLocalRatioToSeconds(ratio));
      },
      onHorizontalDragEnd: (_) {
        final committed = _scrubSeconds;
        setState(() => _scrubSeconds = null);
        if (committed != null) widget.onSeek(committed);
      },
      onHorizontalDragCancel: () {
        setState(() => _scrubSeconds = null);
      },
      onTapDown: (details) {
        final ratio = ratioFromGlobal(details.globalPosition);
        widget.onSeek(mapLocalRatioToSeconds(ratio));
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
              if (widget.isPreviewOnly && widget.durationSeconds > 0)
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
                key: ValueKey(widget.durationSeconds),
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
