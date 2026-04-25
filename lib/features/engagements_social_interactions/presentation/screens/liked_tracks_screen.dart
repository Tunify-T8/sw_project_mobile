import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/liked_track_entity.dart';
import '../provider/enagement_providers.dart';
import '../utils/engagement_formatters.dart';
import '../../../../features/playback_streaming_engine/presentation/widgets/track_options_sheet.dart';

class LikedTracksScreen extends ConsumerStatefulWidget {
  const LikedTracksScreen({super.key});

  @override
  ConsumerState<LikedTracksScreen> createState() => _LikedTracksScreenState();
}

class _LikedTracksScreenState extends ConsumerState<LikedTracksScreen> {
  static const String _viewerId = 'user_current_1';

  List<LikedTrackEntity> _tracks = [];
  List<LikedTrackEntity> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _tracks
          : _tracks.where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.artistName.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _load() async {
    try {
      final tracks = await ref
          .read(getLikedTracksUsecaseProvider)
          .call(viewerId: _viewerId);
      if (mounted) {
        for (final t in tracks) {
          ref.read(engagementProvider(t.trackId).notifier).seedFromFeed(
            likeCount: t.likesCount,
            commentCount: t.commentsCount,
            repostCount: 0,
            isLiked: true,
            isReposted: false,
          );
        }
        setState(() { _tracks = tracks; _filtered = tracks; _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // Returns only tracks that are still liked according to live engagement state.
  // ref.watch calls here mean this screen rebuilds whenever any track is unliked
  // from anywhere in the app.
  List<LikedTrackEntity> _visibleTracks() {
    return _filtered.where((t) {
      final engagement = ref.watch(engagementProvider(t.trackId)).engagement;
      return engagement?.isLiked != false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleTracks();
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${visible.length} Likes',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              key: const Key('liked_tracks_search_field'),
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search ${_tracks.length} tracks',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.download_outlined, color: Colors.white54, size: 26),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.shuffle, color: Colors.white54, size: 26),
                  onPressed: () {},
                ),
                Container(
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(visible)),
        ],
      ),
    );
  }

  Widget _buildBody(List<LikedTrackEntity> visible) {
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
    if (visible.isEmpty) {
      return const Center(
        child: Text('No results', style: TextStyle(color: Colors.white54, fontSize: 16)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: visible.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) => _LikedTrackTile(track: visible[index]),
    );
  }
}

class _LikedTrackTile extends ConsumerWidget {
  const _LikedTrackTile({required this.track});
  final LikedTrackEntity track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: _buildCover(),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 3),
                Text(
                  EngagementFormatters.timestamp(track.duration),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => showTrackOptionsSheet(
              context,
              info: TrackOptionInfo(
                trackId: track.trackId,
                title: track.title,
                artist: track.artistName,
                artistId: track.artistId,
                coverUrl: track.coverUrl,
              ),
              ref: ref,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    final url = track.coverUrl ?? track.artistAvatar;
    if (url != null) {
      return Image.network(
        url,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
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
