// lib/features/feed_search_discovery/presentation/widgets/search/search_result_tile_album.dart

import 'package:flutter/material.dart';
import '../../../domain/entities/album_result_entity.dart';
import 'search_artwork_placeholder.dart';

class SearchResultTileAlbum extends StatelessWidget {
  const SearchResultTileAlbum({super.key, required this.album});
  final AlbumResultEntity album;

  @override
  Widget build(BuildContext context) {
    final yearStr = album.releaseYear != null ? ' · ${album.releaseYear}' : '';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: album.artworkUrl != null
            ? Image.network(
                album.artworkUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              )
            : SearchArtworkPlaceholder(size: 48),
      ),
      title: Text(
        album.title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${album.artistName}$yearStr · ${album.trackCount} tracks',
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
    );
  }
}
