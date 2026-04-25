import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../features/audio_upload_and_management/presentation/widgets/upload_artwork_view.dart';

class TrackOptionsHeader extends StatelessWidget {
  final String title;
  final String artistName;
  final String? coverUrl;
  final String? localArtworkPath;

  const TrackOptionsHeader({
    super.key,
    required this.title,
    required this.artistName,
    this.coverUrl,
    this.localArtworkPath,
  });

  @override
  Widget build(BuildContext context) {
    final hasArtwork = coverUrl != null || localArtworkPath != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              if (hasArtwork)
                Positioned.fill(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 20),
                    child: UploadArtworkView(
                      localPath: localArtworkPath,
                      remoteUrl: coverUrl,
                      width: double.infinity,
                      height: double.infinity,
                      backgroundColor: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.zero,
                      placeholder: const SizedBox.shrink(),
                    ),
                  ),
                )
              else
                Positioned.fill(
                  child: Container(color: const Color(0xFF2A2A2A)),
                ),

              Positioned.fill(child: Container(color: Colors.black54)),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 100,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 36,
                            top: 6,
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF2A2A2A),
                              ),
                              child: const Icon(
                                Icons.album,
                                color: Colors.white24,
                                size: 70,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: hasArtwork
                                  ? UploadArtworkView(
                                      localPath: localArtworkPath,
                                      remoteUrl: coverUrl,
                                      width: 100,
                                      height: 100,
                                      backgroundColor:
                                          const Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(8),
                                      placeholder: const Icon(
                                        Icons.music_note,
                                        color: Colors.white24,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.music_note,
                                      color: Colors.white24,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}