import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../playback_streaming_engine/domain/entities/history_track.dart';
import '../../../domain/entities/upload_item.dart';
import '../../providers/track_detail_item_provider.dart';
import '../upload_artwork_view.dart';

part 'home_recent_section_recent_card.dart';
part 'home_recent_section_placeholder_card.dart';

/// Shows a 2-column grid of recently played tracks on the home screen.
///
/// Priority:
///   1. [historyTracks] — tracks from listening history (most recently played first)
///   2. [latestTrack] — fallback to the user's most recent upload
///   3. Placeholder cards if neither is available
class HomeRecentSection extends StatelessWidget {
  const HomeRecentSection({
    super.key,
    required this.latestTrack,
    required this.onOpenTrack,
    this.onOpenHistoryTrack,
    this.historyTracks = const [],
  });

  final UploadItem? latestTrack;
  final List<HistoryTrack> historyTracks;
  final ValueChanged<UploadItem> onOpenTrack;
  final ValueChanged<HistoryTrack>? onOpenHistoryTrack;

  static const _placeholders = [
    _PlaceholderData(
      label: 'Sherine - Sabry Aalil',
      sub: 'Sherine',
      color: Color(0xFF72495F),
    ),
    _PlaceholderData(
      label: 'Ana Sabry Aaleel',
      sub: 'Alya Al Hashemi',
      color: Color(0xFF8B6679),
    ),
    _PlaceholderData(
      label: 'Enta Eih',
      sub: 'SaRa Ahmed',
      color: Color(0xFF565656),
    ),
    _PlaceholderData(
      label: 'Ocean Eyes',
      sub: 'Billie Eilish',
      color: Color(0xFF2A4E72),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Build grid items from history first, then fill with placeholders
    final cards = <Widget>[];

    // Add up to 4 history-based cards
    final recentHistoryItems = historyTracks.take(4).toList();
    for (final historyTrack in recentHistoryItems) {
      cards.add(
        _HistoryRecentCard(
          historyTrack: historyTrack,
          onTap: () {
            final historyLauncher = onOpenHistoryTrack;
            if (historyLauncher != null) {
              historyLauncher(historyTrack);
              return;
            }

            // Convert to minimal UploadItem so the launcher can open it.
            final item = UploadItem(
              id: historyTrack.trackId,
              title: historyTrack.title,
              artistDisplay: historyTrack.artist.name,
              durationLabel: _fmtDuration(historyTrack.durationSeconds),
              durationSeconds: historyTrack.durationSeconds,
              artworkUrl: historyTrack.coverUrl,
              visibility: UploadVisibility.public,
              status: UploadProcessingStatus.finished,
              isExplicit: false,
              createdAt: historyTrack.playedAt,
            );
            onOpenTrack(item);
          },
        ),
      );
    }

    // If no history at all, show upload-based card if available
    if (cards.isEmpty && latestTrack != null) {
      cards.add(
        _RecentCard(
          item: latestTrack!,
          onTap: () => onOpenTrack(latestTrack!),
        ),
      );
    }

    // Fill remaining slots with placeholders up to 4 total
    int placeholderIndex = 0;
    while (cards.length < 4 && placeholderIndex < _placeholders.length) {
      final p = _placeholders[placeholderIndex];
      cards.add(
        _PlaceholderCard(label: p.label, sub: p.sub, color: p.color),
      );
      placeholderIndex++;
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.85,
        ),
        delegate: SliverChildListDelegate(cards),
      ),
    );
  }

  String _fmtDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _PlaceholderData {
  const _PlaceholderData({
    required this.label,
    required this.sub,
    required this.color,
  });
  final String label;
  final String sub;
  final Color color;
}