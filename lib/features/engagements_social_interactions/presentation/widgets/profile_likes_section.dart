import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/liked_track_entity.dart';
import '../provider/enagement_providers.dart';
import '../screens/liked_tracks_screen.dart';
import '../utils/engagement_formatters.dart';
import '../../../../features/playback_streaming_engine/presentation/widgets/track_options_sheet.dart';
import '../../../../shared/ui/widgets/track_options_menu/track_options_menu.dart';

class ProfileLikesSection extends ConsumerStatefulWidget {
  /// null → current user, non-null → another user
  const ProfileLikesSection({super.key, this.userId});

  final String? userId;

  @override
  ConsumerState<ProfileLikesSection> createState() => _ProfileLikesSectionState();
}

class _ProfileLikesSectionState extends ConsumerState<ProfileLikesSection> {
  static const int _previewCount = 2;

  List<LikedTrackEntity> _tracks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tracks = await ref
          .read(getLikedTracksUsecaseProvider)
          .call(viewerId: widget.userId ?? '');
      if (mounted) {
        // Seed engagement state as liked
        for (final t in tracks) {
          ref.read(engagementProvider(t.trackId).notifier).seedFromFeed(
            likeCount: t.likesCount,
            commentCount: t.commentsCount,
            repostCount: 0,
            isLiked: true,
            isReposted: false,
          );
        }
        setState(() { _tracks = tracks; _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && _tracks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 9),
                child: Text(
                  'Likes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Key: EngagementKeys.likesSeeAllButton
              TextButton(
                key: const Key('likes_see_all_button'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LikedTracksScreen(),
                  ),
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.orangeAccent,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tracks.take(_previewCount).length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) =>
                  _LikePreviewTile(track: _tracks[index]),
            ),
        ],
      ),
    );
  }
}

class _LikePreviewTile extends ConsumerWidget {
  const _LikePreviewTile({required this.track});
  final LikedTrackEntity track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // cover → fallback to artistAvatar → placeholder
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
                Row(
                  children: [
                    const Icon(Icons.play_arrow, size: 12, color: Colors.white38),
                    const SizedBox(width: 3),
                    Text(
                      EngagementFormatters.timestamp(track.duration),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
                await showTrackOptionsMenu(
                  context: context,
                  trackId: track.trackId,
                  title: track.title,
                  artistId: track.artistId,
                  artistName: track.artistName,
                  coverUrl: track.coverUrl,
                  initialIsLiked: true,
                );
              },
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
