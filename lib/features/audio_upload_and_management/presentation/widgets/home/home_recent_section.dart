import 'package:flutter/material.dart';

import '../../../domain/entities/upload_item.dart';
import '../upload_artwork_view.dart';

class HomeRecentSection extends StatelessWidget {
  const HomeRecentSection({
    super.key,
    required this.latestTrack,
    required this.onOpenTrack,
  });

  final UploadItem? latestTrack;
  final ValueChanged<UploadItem> onOpenTrack;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 3.2,
        ),
        delegate: SliverChildListDelegate([
          if (latestTrack != null) ...[
            _RecentCard(
              item: latestTrack!,
              onTap: () => onOpenTrack(latestTrack!),
            ),
            const _PlaceholderCard(label: 'stateside + z...', sub: 'Playlist'),
            const _PlaceholderCard(label: 'Pop Fit Workout', sub: 'Discovery'),
            const _PlaceholderCard(label: 'Your Side Again', sub: 'Yungex 69'),
          ] else ...[
            const _PlaceholderCard(label: 'Ocean Eyes', sub: 'Billie Eilish'),
            const _PlaceholderCard(label: 'stateside + z...', sub: 'Playlist'),
            const _PlaceholderCard(label: 'Pop Fit Workout', sub: 'Discovery'),
            const _PlaceholderCard(label: 'Your Side Again', sub: 'Yungex 69'),
          ],
        ]),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.item, required this.onTap});

  final UploadItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            UploadArtworkView(
              localPath: item.localArtworkPath,
              remoteUrl: item.artworkUrl,
              width: 48,
              height: double.infinity,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(6),
              ),
              backgroundColor: const Color(0xFF3A4A5A),
              placeholder: const Icon(
                Icons.person,
                color: Color(0xFF6A8AAA),
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    item.artistDisplay,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.label, required this.sub});

  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF2A3A4A),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
            ),
            child: const Icon(
              Icons.music_note,
              color: Color(0xFF4A6A8A),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
