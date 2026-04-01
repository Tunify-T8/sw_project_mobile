import 'package:flutter/material.dart';
import '../../../domain/entities/album_result_entity.dart';
import 'search_artwork_placeholder.dart';

class SearchResultTileAlbum extends StatelessWidget {
  const SearchResultTileAlbum({super.key, required this.album});
  final AlbumResultEntity album;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        style: const TextStyle(
          color: Colors.white,
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
            album.artistName,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(
                Icons.favorite_border,
                color: Colors.white38,
                size: 12,
              ),
              const SizedBox(width: 3),
              Text(
                _fmt(album.likesCount),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 4),
              const Text(
                '·',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 4),
              const Text(
                'Album',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 4),
              const Text(
                '·',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 4),
              Text(
                '${album.trackCount} Tracks',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }
}
