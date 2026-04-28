import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../../features/playlists/presentation/widgets/select_playlist_sheet.dart';
import '../../../../features/playback_streaming_engine/presentation/providers/player_provider.dart';
import 'track_option_menu_item.dart';

class TrackActions extends ConsumerWidget {
  final String trackId;
  final bool isLiked;
  final bool isMyTrack;
  final bool isDiscoverFeed;
  final bool isFollowingFeed;

  const TrackActions({
    super.key,
    required this.trackId,
    required this.isLiked,
    required this.isMyTrack,
    required this.isDiscoverFeed,
    required this.isFollowingFeed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (!isMyTrack)
          TrackOptionMenuItem(
            key: const Key('track_options_like_item'),
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: isLiked ? 'Liked' : 'Like',
            color: isLiked ? Colors.orange : Colors.white,
            onTap: () {
              ref.read(engagementProvider(trackId).notifier).toggleLike();
              Navigator.pop(context);
            },
          ),

        TrackOptionMenuItem(
          icon: Icons.queue_play_next,
          label: 'Play next',
          onTap: () {
            ref.read(playerProvider.notifier).addToQueueNext(trackId);
            Navigator.pop(context);
          },
        ),

        TrackOptionMenuItem(
          icon: Icons.add_to_queue,
          label: 'Play last',
          onTap: () {
            ref.read(playerProvider.notifier).addToQueueLast(trackId);
            Navigator.pop(context);
          },
        ),

        TrackOptionMenuItem(
          icon: Icons.playlist_add,
          label: 'Add to playlist',
          onTap: () {
            final navigator = Navigator.of(context);
            final targetContext = navigator.context;
            navigator.pop();
            showSelectPlaylistSheet(
              context: targetContext,
              ref: ref,
              trackId: trackId,
            );
          },
        ),

        if (!isDiscoverFeed && !isFollowingFeed && !isMyTrack)
          TrackOptionMenuItem(
            icon: Icons.sensors,
            label: 'Start station',
            onTap: () {},
          ),
      ],
    );
  }
}
