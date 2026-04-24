import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track_preview_entity.dart';
import '../../../engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../engagements_social_interactions/presentation/screens/comments_screen.dart';
import '../../domain/entities/feed_view_mode.dart';
import '../providers/feed_view_provider.dart';
import '../../../engagements_social_interactions/presentation/widgets/repost_caption_sheet.dart';
import 'package:software_project/features/profile/presentation/screens/other_user_profile_screen.dart';

class FeedMenuSheet extends ConsumerWidget {
  // engagement modification — was StatelessWidget, converted to ConsumerWidget
  final TrackPreviewEntity track;
  final FeedViewMode feedViewMode;

  const FeedMenuSheet({
    super.key,
    required this.track,
    required this.feedViewMode,
  });

  Widget _createMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  List<Widget> _trackActions(BuildContext context, WidgetRef ref) {
    final engagementState = ref.watch(engagementProvider(track.trackId));
    final isLiked =
        engagementState.engagement?.isLiked ?? track.interaction.isLiked;
    final isReposted =
        engagementState.engagement?.isReposted ?? track.interaction.isReposted;
    return [
      _createMenuItem(
        icon: isLiked ? Icons.favorite : Icons.favorite_border,
        label: isLiked ? 'Liked' : 'Like',
        color: isLiked ? Colors.orange : Colors.white,
        onTap: () {
          ref.read(engagementProvider(track.trackId).notifier).toggleLike();
          Navigator.pop(context);
        },
      ),
      _createMenuItem(
        icon: Icons.queue_play_next,
        label: 'Play next',
        onTap: () {},
      ),
      _createMenuItem(
        icon: Icons.add_to_queue,
        label: 'Play last',
        onTap: () {},
      ),
      _createMenuItem(
        icon: Icons.playlist_add,
        label: 'Add to playlist',
        onTap: () {},
      ),
    ];
  }

  List<Widget> _socialActions(
    BuildContext context,
    WidgetRef ref,
    bool isReposted,
  ) => [
    _createMenuItem(
      icon: Icons.person_outline,
      label: 'Go to profile',
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtherUserProfileScreen(userId: track.artistId),
          ),
        );
      },
    ),
    _createMenuItem(
      icon: Icons.comment_outlined,
      label: 'View comments',
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommentsScreen(trackId: track.trackId),
          ),
        );
      },
    ),
    _createMenuItem(
      icon: isReposted ? Icons.repeat_on : Icons.repeat,
      label: isReposted ? 'Reposted' : 'Repost',
      color: isReposted ? Colors.orange : Colors.white,
      onTap: () {
        Navigator.pop(context);
        if (isReposted) {
          ref.read(engagementProvider(track.trackId).notifier).removeRepost();
        } else {
          RepostCaptionSheet.show(
            context,
            trackId: track.trackId,
            trackTitle: track.title,
            artistName: track.artistName,
            coverUrl: track.coverUrl,
          );
        }
      },
    ),
  ];

  List<Widget> _moreOptions() => [
    _createMenuItem(
      icon: Icons.graphic_eq,
      label: 'Behind this track',
      onTap: () {},
    ),
    _createMenuItem(icon: Icons.flag_outlined, label: 'Report', onTap: () {}),
  ];

  Widget _trackHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 100,
            child: Stack(
              children: [
                Positioned(
                  left: 40.0,
                  child: Container(
                    width: 80,
                    height: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2A2A2A),
                    ),
                    child: const Icon(
                      Icons.album,
                      color: Colors.white24,
                      size: 80,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: track.coverUrl != null
                          ? DecorationImage(
                              image: NetworkImage(track.coverUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: track.coverUrl == null
                        ? const Icon(
                            Icons.music_note,
                            color: Colors.white24,
                            size: 40,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  track.artistName,
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReposted =
        (ref.watch(engagementProvider(track.trackId)).engagement?.isReposted) ??
        track.interaction.isReposted;
    return ListView(
      children: [
        _trackHeader(),
        const Divider(color: Colors.white12),
        ..._trackActions(context, ref),
        const Divider(color: Colors.white12),
        ..._socialActions(context, ref, isReposted),

        if (feedViewMode == FeedViewMode.discover) ...[
          const Divider(color: Colors.white12),
          _createMenuItem(
            icon: Icons.swap_horiz,
            label: 'Switch to Classic feed',
            onTap: () {
              Navigator.pop(context);
              ref.read(feedViewModeProvider.notifier).setMode(FeedViewMode.classic);
            },
          ),
        ],

        const Divider(color: Colors.white12),
        ..._moreOptions(),
      ],
    );
  }
}
