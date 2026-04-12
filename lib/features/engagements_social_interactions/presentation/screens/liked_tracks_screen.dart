import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/liked_track_entity.dart';
import '../provider/enagement_providers.dart';
import '../utils/engagement_formatters.dart';

class LikedTracksScreen extends ConsumerStatefulWidget {
  const LikedTracksScreen({super.key});

  @override
  ConsumerState<LikedTracksScreen> createState() => _LikedTracksScreenState();
}

class _LikedTracksScreenState extends ConsumerState<LikedTracksScreen> {
  static const String _viewerId = 'user_current_1'; // swap with real auth later

  List<LikedTrackEntity> _tracks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tracks = await ref
          .read(getLikedTracksUsecaseProvider)
          .call(viewerId: _viewerId);
      if (mounted) setState(() { _tracks = tracks; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${_tracks.length} Likes',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.white54)),
      );
    }
    if (_tracks.isEmpty) {
      return const Center(
        child: Text(
          'No liked tracks yet',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _tracks.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) => _LikedTrackTile(track: _tracks[index]),
    );
  }
}

class _LikedTrackTile extends StatelessWidget {
  const _LikedTrackTile({required this.track});
  final LikedTrackEntity track;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // cover art
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: track.coverUrl != null
                ? Image.network(
                    track.coverUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          // title + artist
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  track.artistName,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // liked-at time + duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                EngagementFormatters.timeAgo(track.likedAt),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                EngagementFormatters.timestamp(track.duration),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 52,
      height: 52,
      color: Colors.white10,
      child: const Icon(Icons.music_note, color: Colors.white24, size: 26),
    );
  }
}
