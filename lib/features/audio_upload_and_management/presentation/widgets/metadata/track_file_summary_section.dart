import 'package:flutter/material.dart';

import 'track_file_artwork_tile.dart';
import 'upload_progress_pill.dart';

class TrackFileSummarySection extends StatelessWidget {
  const TrackFileSummarySection({
    super.key,
    required this.displayedFileName,
    required this.artworkPath,
    required this.uploadFinished,
    required this.isPreparingUpload,
    required this.isUploading,
    required this.uploadProgress,
    required this.onPickArtwork,
    required this.onReplaceAudio,
  });

  final String displayedFileName;
  final String? artworkPath;
  final bool uploadFinished;
  final bool isPreparingUpload;
  final bool isUploading;
  final double uploadProgress;
  final VoidCallback onPickArtwork;
  final VoidCallback onReplaceAudio;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrackFileArtworkTile(artworkPath: artworkPath, onTap: onPickArtwork),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filename',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                displayedFileName,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 14),
              if (!uploadFinished)
                UploadProgressPill(
                  isPreparingUpload: isPreparingUpload,
                  isUploading: isUploading,
                  progress: uploadProgress,
                )
              else
                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                      ),
                      onPressed: onReplaceAudio,
                      child: const Text('Replace'),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF37B26C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.black),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
