import 'package:flutter/material.dart';

import '../../domain/entities/playlist_track_entity.dart';

class PlaylistTrackTile extends StatelessWidget {
  const PlaylistTrackTile({
    super.key,
    required this.track,
    required this.onTap,
    required this.onMoreTap,
  });

  final PlaylistTrackEntity track;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _Cover(coverUrl: track.coverUrl),
            const SizedBox(width: 12),
            Expanded(child: _Info(track: track)),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white38),
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
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl != null
          ? Image.network(coverUrl!, fit: BoxFit.cover)
          : const Icon(Icons.music_note, color: Colors.white24, size: 26),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.track});
  final PlaylistTrackEntity track;

  String get _duration {
    final m = track.durationSeconds ~/ 60;
    final s = track.durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get _playCount {
    final c = track.playCount;
    if (c >= 1000000) return '${(c / 1000000).toStringAsFixed(1)}M';
    if (c >= 1000) return '${(c / 1000).toStringAsFixed(1)}K';
    return c.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          track.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          track.ownerDisplayName ?? track.ownerUsername,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.play_arrow, color: Colors.white38, size: 14),
            const SizedBox(width: 2),
            Text(
              '$_playCount · $_duration',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
