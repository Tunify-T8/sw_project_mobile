// lib/features/feed_search_discovery/presentation/widgets/search/search_result_tile_playlist.dart

import 'package:flutter/material.dart';
import '../../../domain/entities/playlist_result_entity.dart';
import 'search_artwork_placeholder.dart';

class SearchResultTilePlaylist extends StatelessWidget {
  const SearchResultTilePlaylist({super.key, required this.playlist});
  final PlaylistResultEntity playlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: playlist.artworkUrl != null
            ? Image.network(
                playlist.artworkUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              )
            : SearchArtworkPlaceholder(size: 48),
      ),
      title: Text(
        playlist.title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${playlist.creatorName} · ${playlist.trackCount} tracks',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
    );
  }
}
