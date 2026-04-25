import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reposted_track_entity.dart';
import '../provider/enagement_providers.dart';
import '../screens/user_reposts_screen.dart';
import '../utils/engagement_formatters.dart';
import '../../../../features/playback_streaming_engine/presentation/widgets/track_options_sheet.dart';

class ProfileRepostsSection extends ConsumerStatefulWidget {
  /// null → current user (GET /users/me/reposts)
  /// non-null → another user (GET /users/{userId}/reposts)
  const ProfileRepostsSection({super.key, this.userId});

  final String? userId;

  @override
  ConsumerState<ProfileRepostsSection> createState() =>
      _ProfileRepostsSectionState();
}

class _ProfileRepostsSectionState extends ConsumerState<ProfileRepostsSection> {
  static const int _previewCount = 2;

  List<RepostedTrackEntity> _tracks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tracks = await ref
          .read(getUserRepostsUsecaseProvider)
          .call(userId: widget.userId);
      if (mounted) setState(() { _tracks = tracks; _loading = false; });
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
                  'Reposts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Key: EngagementKeys.repostsSeeAllButton
              TextButton(
                key: const Key('reposts_see_all_button'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserRepostsScreen(userId: widget.userId),
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
                  _RepostPreviewTile(track: _tracks[index]),
            ),
        ],
      ),
    );
  }
}

class _RepostPreviewTile extends ConsumerWidget {
  const _RepostPreviewTile({required this.track});
  final RepostedTrackEntity track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
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
                      EngagementFormatters.compactCount(track.playCount),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
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

  Widget _placeholder() {
    return Container(
      width: 52,
      height: 52,
      color: Colors.white10,
      child: const Icon(Icons.music_note, color: Colors.white24, size: 26),
    );
  }
}
