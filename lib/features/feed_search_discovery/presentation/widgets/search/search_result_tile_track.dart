import 'package:flutter/material.dart';
import '../../../domain/entities/track_result_entity.dart';
import 'search_artwork_placeholder.dart';

class SearchResultTileTrack extends StatelessWidget {
  const SearchResultTileTrack({super.key, required this.track});
  final TrackResultEntity track;

  @override
  Widget build(BuildContext context) {
    final duration = _formatDuration(track.durationSeconds);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: track.artworkUrl != null
            ? Image.network(
                track.artworkUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              )
            : SearchArtworkPlaceholder(size: 48),
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
            ),
        ],
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
