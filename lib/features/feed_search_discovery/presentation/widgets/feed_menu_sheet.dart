import 'package:flutter/material.dart';
import '../../domain/entities/track_preview_entity.dart';
import '../../domain/entities/feed_item_entity.dart';
import '../../domain/entities/feed_tab_type.dart';

class FeedMenuSheet extends StatelessWidget {
  final TrackPreviewEntity track;
  final FeedTabType tabType;

  const FeedMenuSheet({super.key, required this.track, required this.tabType});

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

  List<Widget> _trackActions() => [
    _createMenuItem(
      icon: track.interaction.isLiked ? Icons.favorite : Icons.favorite_border,
      label: track.interaction.isLiked ? 'Liked' : 'Like',
      color: track.interaction.isLiked ? Colors.orange : Colors.white,
      onTap: () {},
    ),
    _createMenuItem(
      icon: Icons.queue_play_next,
      label: 'Play next',
      onTap: () {},
    ),
    _createMenuItem(icon: Icons.add_to_queue, label: 'Play last', onTap: () {}),
    _createMenuItem(
      icon: Icons.playlist_add,
      label: 'Add to playlist',
      onTap: () {},
    ),
  ];

  List<Widget> _socialActions() => [
    _createMenuItem(
      icon: Icons.person_outline,
      label: 'Go to profile',
      onTap: () {},
    ),
    _createMenuItem(
      icon: Icons.comment_outlined,
      label: 'View comments',
      onTap: () {},
    ),
    _createMenuItem(
      icon: Icons.repeat,
      label: track.interaction.isReposted ? 'Reposted' : 'Repost',
      color: track.interaction.isReposted ? Colors.orange : Colors.white,
      onTap: () {},
    ),
  ];

  List<Widget> _feedControls() => [
    if (tabType == FeedTabType.discover)
      _createMenuItem(
        icon: Icons.thumb_down_outlined,
        label: 'Show me fewer posts like this',
        onTap: () {},
      ),
    _createMenuItem(
      icon: Icons.swap_horiz,
      label: 'Switch to Classic feed',
      onTap: () {},
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
                  child: const Icon(Icons.album, color: Colors.white24, size: 80),
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
                          )
                        : null,
                  ),
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
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
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
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _trackHeader(),
        const Divider(color: Colors.white12),
        ..._trackActions(),
        const Divider(color: Colors.white12),
        ..._socialActions(),
        const Divider(color: Colors.white12),
        ..._feedControls(),
        const Divider(color: Colors.white12),
        ..._moreOptions(),
      ],
    );
  }
}
