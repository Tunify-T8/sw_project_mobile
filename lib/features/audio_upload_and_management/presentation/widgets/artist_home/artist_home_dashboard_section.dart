// Upload Feature Guide:
// Purpose: Artist dashboard widget used by ArtistHomeScreen.
// Used by: artist_home_screen
// Concerns: Supporting UI and infrastructure for upload and track management.
import 'package:flutter/material.dart';

class ArtistHomeDashboardSection extends StatelessWidget {
  const ArtistHomeDashboardSection({
    super.key,
    required this.isBusy,
    required this.busyLabel,
    required this.onUpload,
    required this.onOpenUploads,
    required this.onOpenAlbums,
  });

  final bool isBusy;
  final String busyLabel;
  final VoidCallback onUpload;
  final VoidCallback onOpenUploads;
  final VoidCallback onOpenAlbums;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: isBusy ? null : onUpload,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3D1466), Color(0xFF6B1FA3)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isBusy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  const SizedBox(width: 10),
                  Text(
                    isBusy ? busyLabel : 'Upload a track',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _DarkCard(
            icon: Icons.graphic_eq,
            label: 'Uploads',
            onTap: onOpenUploads,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _DarkCard(
            icon: Icons.album_outlined,
            label: 'Albums',
            onTap: onOpenAlbums,
          ),
        ),
      ],
    );
  }
}

class _DarkCard extends StatelessWidget {
  const _DarkCard({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
