import 'dart:io';

import 'package:flutter/material.dart';


// refactor again
class TrackFileSummarySection extends StatelessWidget {
  final String displayedFileName;
  final String? artworkPath;
  final bool uploadFinished;
  final bool isPreparingUpload;
  final bool isUploading;
  final double uploadProgress;
  final VoidCallback onPickArtwork;
  final VoidCallback onReplaceAudio;

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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ArtworkTile(
          artworkPath: artworkPath,
          onTap: onPickArtwork,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filename',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                displayedFileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 14),
              if (!uploadFinished)
                _UploadProgressPill(
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
                      child: const Icon(
                        Icons.check,
                        color: Colors.black,
                      ),
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

class _ArtworkTile extends StatelessWidget {
  final String? artworkPath;
  final VoidCallback onTap;

  const _ArtworkTile({
    required this.artworkPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white54,
            width: 1.2,
          ),
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
                child: Image.file(
                  File(artworkPath!),
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}

class _UploadProgressPill extends StatelessWidget {
  final bool isPreparingUpload;
  final bool isUploading;
  final double progress;

  const _UploadProgressPill({
    required this.isPreparingUpload,
    required this.isUploading,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    String label;

    if (isPreparingUpload) {
      label = 'PREPARING TO UPLOAD';
    } else if (isUploading) {
      label = 'UPLOADING ${(progress * 100).toStringAsFixed(0)}%';
    } else {
      label = 'UPLOADING 100%';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF0C5F3B),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: isPreparingUpload ? 0.15 : progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF11A85B),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            const Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(),
                    ),
                    Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
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