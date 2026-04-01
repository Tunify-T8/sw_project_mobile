import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/upload_item.dart';
import '../../providers/track_detail_item_provider.dart';
import '../upload_artwork_view.dart';

part 'home_recent_section_recent_card.dart';
part 'home_recent_section_placeholder_card.dart';

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
            _RecentCard(
              item: latestTrack!,
              onTap: () => onOpenTrack(latestTrack!),
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
