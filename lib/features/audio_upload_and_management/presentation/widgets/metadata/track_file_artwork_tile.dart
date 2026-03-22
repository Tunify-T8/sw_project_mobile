// Upload Feature Guide:
// Purpose: Metadata form widget used inside TrackMetadataScreen and TrackMetadataBody.
// Used by: track_file_summary_section
// Concerns: Metadata engine.
import 'dart:io';

import 'package:flutter/material.dart';

class TrackFileArtworkTile extends StatelessWidget {
  const TrackFileArtworkTile({
    super.key,
    required this.artworkPath,
    required this.onTap,
  });

  final String? artworkPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white54, width: 1.2),
        ),
        child: artworkPath == null || artworkPath!.isEmpty
            ? const Center(
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: artworkPath!.startsWith('http')
                    ? Image.network(
                        artworkPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Color(0xFF1A1A1A),
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white54,
                              size: 28,
                            ),
                          ),
                        ),
                      )
                    : Image.file(File(artworkPath!), fit: BoxFit.cover),
              ),
      ),
    );
  }
}
