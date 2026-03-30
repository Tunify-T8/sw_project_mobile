// lib/features/feed_search_discovery/presentation/widgets/search/search_result_tile_track.dart

import 'package:flutter/material.dart';
import '../../../domain/entities/track_result_entity.dart';
import 'search_artwork_placeholder.dart';

class SearchResultTileTrack extends StatelessWidget {
  const SearchResultTileTrack({super.key, required this.track});
  final TrackResultEntity track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            track.artistName,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          if (track.isUnavailable)
            const Text(
              'Not available in your country',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (track.playCount != null)
            Text(
              '▶ ${track.playCount}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert, color: Colors.white38, size: 20),
        ],
      ),
    );
  }
}
