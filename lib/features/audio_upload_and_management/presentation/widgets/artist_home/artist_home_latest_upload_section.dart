import 'package:flutter/material.dart';

import '../../../domain/entities/upload_item.dart';
import '../upload_artwork_view.dart';

class ArtistHomeLatestUploadSection extends StatelessWidget {
  const ArtistHomeLatestUploadSection({super.key, required this.latest});

  final UploadItem? latest;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Latest upload',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: latest == null
              ? const _EmptyLatest()
              : _LatestTile(item: latest!),
        ),
      ],
    );
  }
}

class _LatestTile extends StatelessWidget {
  const _LatestTile({required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          UploadArtworkView(
            localPath: item.localArtworkPath,
            remoteUrl: item.artworkUrl,
            width: 48,
            height: 48,
            backgroundColor: const Color(0xFF3A4A5A),
            placeholder: const Icon(
              Icons.account_circle_rounded,
              color: Color(0xFF4872D7),
              size: 38,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.durationLabel,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_horiz, color: Colors.white54, size: 22),
        ],
      ),
    );
  }
}

class _EmptyLatest extends StatelessWidget {
  const _EmptyLatest();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'No uploads yet',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
