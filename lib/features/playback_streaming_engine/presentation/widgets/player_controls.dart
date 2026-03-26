import 'package:flutter/material.dart';

/// Central transport controls row: previous, play/pause, next.
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.hasQueue,
    required this.onPlay,
    required this.onPause,
    required this.onNext,
    required this.onPrevious,
  });

  final bool isPlaying;
  final bool hasQueue;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 36),
          color: hasQueue ? Colors.white : Colors.white30,
          onPressed: hasQueue ? onPrevious : null,
        ),

        const SizedBox(width: 16),

        // Play / pause — large circle button
        GestureDetector(
          onTap: isPlaying ? onPause : onPlay,
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Next
        IconButton(
          icon: const Icon(Icons.skip_next, size: 36),
          color: hasQueue ? Colors.white : Colors.white30,
          onPressed: hasQueue ? onNext : null,
        ),
      ],
    );
  }
}
