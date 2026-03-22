// Upload Feature Guide:
// Purpose: Track detail widget used to build TrackDetailScreen.
// Used by: Referenced by nearby upload feature files.
// Concerns: Track visibility.
import 'package:flutter/material.dart';

class TrackDetailPlayControls extends StatelessWidget {
  const TrackDetailPlayControls({super.key, required this.onPlayPause});

  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: 40),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.skip_next_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
