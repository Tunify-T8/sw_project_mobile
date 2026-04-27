import 'package:flutter/material.dart';

import '../../domain/entities/collection_type.dart';
import '../../domain/entities/playlist_summary_entity.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.onMoreTap,
    this.ownerName,
  });

  final PlaylistSummaryEntity playlist;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;
  final String? ownerName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _Cover(coverUrl: playlist.coverUrl),
            const SizedBox(width: 12),
            Expanded(child: _Info(playlist: playlist, ownerName: ownerName)),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white54),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({this.coverUrl});
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl != null
          ? Image.network(coverUrl!, fit: BoxFit.cover)
          : const Icon(Icons.queue_music, color: Colors.white24, size: 30),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.playlist, this.ownerName});
  final PlaylistSummaryEntity playlist;
  final String? ownerName;

  String get _typeLabel =>
      playlist.type == CollectionType.album ? 'Album' : 'Playlist';

  String get _subtitle =>
      '$_typeLabel · ${playlist.trackCount} Track${playlist.trackCount != 1 ? 's' : ''}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          playlist.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (ownerName != null) ...[
          const SizedBox(height: 2),
          Text(
            ownerName!,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 2),
        Text(
          _subtitle,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }
}
