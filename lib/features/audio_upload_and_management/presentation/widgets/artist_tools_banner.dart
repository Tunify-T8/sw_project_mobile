// Upload Feature Guide:
// Purpose: Artist tools/paywall widget used around upload quotas and upgrade prompts.
// Used by: your_uploads_screen
// Concerns: Supporting UI and infrastructure for upload and track management.
import 'package:flutter/material.dart';

class ArtistToolsBanner extends StatelessWidget {
  const ArtistToolsBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF202020),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'View your remaining Artist tools credits',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white70,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
