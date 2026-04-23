import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/track_result_entity.dart';
import '../../../../playback_streaming_engine/presentation/widgets/track_options_sheet.dart';
import 'search_artwork_placeholder.dart';

/// Search result tile for a single track.
///
/// WHY showTrackOptionsSheet (not FeedMenuSheet):
/// [FeedMenuSheet] requires a [TrackPreviewEntity] with an [artistId] field
/// so it can navigate to the artist's profile. [TrackResultEntity] (what search
/// returns) has no [artistId] — the search API doesn't return it. Passing an
/// empty string would open a broken profile screen.
///
/// [showTrackOptionsSheet] with [TrackOptionInfo.fromTrackId] is the correct
/// choice: it only needs trackId / title / artist / coverUrl, all of which we
/// have. It also checks [globalTrackStoreProvider] first, so if the track
/// belongs to the current user it correctly shows the "Edit track" option.
class SearchResultTileTrack extends ConsumerWidget {
  const SearchResultTileTrack({super.key, required this.track, this.onTap});

  final TrackResultEntity track;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = track.durationSeconds > 0
        ? _formatDuration(track.durationSeconds)
        : null;

    return ListTile(
      onTap: track.isUnavailable ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: SizedBox(
        width: 48,
        height: 48,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: track.artworkUrl != null
              ? Image.network(
                  track.artworkUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      SearchArtworkPlaceholder(size: 48),
                )
              : SearchArtworkPlaceholder(size: 48),
        ),
      ),
      title: Text(
        track.title,
        style: TextStyle(
          color: track.isUnavailable ? Colors.white38 : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            track.artistName,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (track.isUnavailable)
            const Text(
              'Not available in your country',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            )
          else
            Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white38, size: 13),
                const SizedBox(width: 2),
                Text(
                  track.playCount ?? '0',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                if (duration != null) ...[
                  const SizedBox(width: 4),
                  const Text(
                    '·',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ],
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
        padding: EdgeInsets.zero,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () {
          final info = TrackOptionInfo.fromTrackId(
            track.id,
            ref,
            fallbackTitle: track.title,
            fallbackArtist: track.artistName,
            fallbackCoverUrl: track.artworkUrl,
          );
          showTrackOptionsSheet(context, info: info, ref: ref);
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
