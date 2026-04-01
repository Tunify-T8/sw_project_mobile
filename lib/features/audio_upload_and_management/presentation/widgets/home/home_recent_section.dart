import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/upload_item.dart';
import '../../providers/track_detail_item_provider.dart';
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
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.85,
        ),
        delegate: SliverChildListDelegate([
          if (latestTrack != null) ...[
            _RecentCard(item: latestTrack!, onTap: () => onOpenTrack(latestTrack!)),
            const _PlaceholderCard(
              label: 'Sherine - Sabry Aalil',
              sub: 'Sherine',
              color: Color(0xFF72495F),
            ),
            const _PlaceholderCard(
              label: 'Ana Sabry Aaleel',
              sub: 'Alya Al Hashemi',
              color: Color(0xFF8B6679),
            ),
            const _PlaceholderCard(
              label: 'Enta Eih',
              sub: 'SaRa Ahmed',
              color: Color(0xFF565656),
            ),
          ] else ...[
            const _PlaceholderCard(
              label: 'Ocean Eyes',
              sub: 'Billie Eilish',
              color: Color(0xFF2A4E72),
            ),
            const _PlaceholderCard(
              label: 'Sherine - Sabry Aalil',
              sub: 'Sherine',
              color: Color(0xFF72495F),
            ),
            const _PlaceholderCard(
              label: 'Ana Sabry Aaleel',
              sub: 'Alya Al Hashemi',
              color: Color(0xFF8B6679),
            ),
            const _PlaceholderCard(
              label: 'Enta Eih',
              sub: 'SaRa Ahmed',
              color: Color(0xFF565656),
            ),
          ],
        ]),
      ),
    );
  }
}

class _RecentCard extends ConsumerWidget {
  const _RecentCard({required this.item, required this.onTap});

  final UploadItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedItemAsync = ref.watch(trackDetailItemProvider(item));
    final resolvedItem = resolvedItemAsync.asData?.value ?? item;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF171717),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: UploadArtworkView(
                localPath: resolvedItem.localArtworkPath,
                remoteUrl: resolvedItem.artworkUrl,
                width: 72,
                height: double.infinity,
                backgroundColor: const Color(0xFF3A4A5A),
                placeholder: const Icon(
                  Icons.music_note,
                  color: Color(0xFF6A8AAA),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resolvedItem.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resolvedItem.artistDisplay,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({
    required this.label,
    required this.sub,
    required this.color,
  });

  final String label;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
            ),
          ),
          const SizedBox(width: 12),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
