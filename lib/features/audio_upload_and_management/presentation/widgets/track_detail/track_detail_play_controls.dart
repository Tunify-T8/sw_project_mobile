// Upload Feature Guide:
// Purpose: Track detail widget used to build TrackDetailScreen.
// Used by: Referenced by nearby upload feature files.
// Concerns: Track visibility.
import 'package:flutter/material.dart';

class TrackDetailPlayControls extends StatelessWidget {
  const TrackDetailPlayControls({
    super.key,
    required this.onPlayPause,
    required this.isPlaying,
    required this.currentPositionSeconds,
    required this.totalDurationSeconds,
  });

  final VoidCallback onPlayPause;
  final bool isPlaying;
  final int currentPositionSeconds;
  final int totalDurationSeconds;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPlaying ? 'Tap screen to pause' : 'Tap screen to play',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatTime(currentPositionSeconds)} / ${_formatTime(totalDurationSeconds)}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final minutes = safeSeconds ~/ 60;
    final remainingSeconds = safeSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
