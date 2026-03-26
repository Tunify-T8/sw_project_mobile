// Upload Feature Guide:
// Purpose: Artist dashboard widget used by ArtistHomeScreen.
// Used by: artist_home_screen
// Concerns: Supporting UI and infrastructure for upload and track management.
import 'package:flutter/material.dart';

class ArtistHomeAppBar extends StatelessWidget {
  const ArtistHomeAppBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: onBack,
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Artist Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
