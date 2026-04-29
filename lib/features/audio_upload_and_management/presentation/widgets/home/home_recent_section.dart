import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../playback_streaming_engine/domain/entities/history_track.dart';
import '../../../domain/entities/upload_item.dart';
import '../../providers/track_detail_item_provider.dart';
import '../upload_artwork_view.dart';

part 'home_recent_section_recent_card.dart';
part 'home_recent_section_placeholder_card.dart';

/// Shows recently played tracks on the home screen.
///
/// Important: this section does not show fake song names. If real/cached data is
/// not ready yet, it shows neutral loading placeholders only.
class HomeRecentSection extends StatelessWidget {
  const HomeRecentSection({
    super.key,
    required this.latestTrack,
    required this.onOpenTrack,
    this.historyTracks = const [],
  });

  final UploadItem? latestTrack;
  final List<HistoryTrack> historyTracks;
  final ValueChanged<UploadItem> onOpenTrack;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1280
        ? 4
        : width >= 900
        ? 3
        : 2;
    final horizontalPadding = width >= 1024 ? 28.0 : 16.0;
    final childAspectRatio = width >= 1024 ? 3.2 : 2.85;
    final cards = <Widget>[];

    final recentHistoryItems = historyTracks.take(4).toList();
    for (final historyTrack in recentHistoryItems) {
      cards.add(
        _HistoryRecentCard(
          historyTrack: historyTrack,
          onTap: () {
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

    if (cards.isEmpty && latestTrack != null) {
      cards.add(
        _RecentCard(item: latestTrack!, onTap: () => onOpenTrack(latestTrack!)),
      );
    }

    while (cards.length < 4) {
      cards.add(const _PlaceholderCard());
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
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
