import 'package:flutter/material.dart';

class FeedPreviewOverlay extends StatelessWidget {
  const FeedPreviewOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Visual prompt shown before preview audio starts. FeedTrackCard removes
    // this overlay when isPreviewing becomes true.
    return Positioned(
      left: 12.0,
      top: 55.0,
      right: 12.0,
      bottom: 20.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(0x70494949),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Tap to Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 23.0,
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            Center(
              child: Container(
                width: 50.0,
                height: 50.0,
                decoration: const BoxDecoration(
                  color: Color(0x99494949),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_off,
                  color: Colors.white,
                  size: 22.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
