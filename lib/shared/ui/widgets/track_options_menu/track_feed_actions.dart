import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'track_option_menu_item.dart';
import '../../../../features/feed_search_discovery/presentation/providers/feed_view_provider.dart';
import '../../../../features/feed_search_discovery/domain/entities/feed_view_mode.dart';

class TrackFeedActions extends ConsumerWidget {
  final bool isDiscoverFeed;

  const TrackFeedActions({
    super.key,
    required this.isDiscoverFeed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (isDiscoverFeed)
          TrackOptionMenuItem(
            icon: Icons.thumb_down,
            label: 'Show me fewer posts like this',
            onTap: () {
              Navigator.pop(context);
              ref
                  .read(feedViewModeProvider.notifier)
                  .setMode(FeedViewMode.classic);
            },
          ),

        TrackOptionMenuItem(
          icon: Icons.swap_horiz,
          label: 'Switch to Classic feed',
          onTap: () {
            Navigator.pop(context);
            ref
                .read(feedViewModeProvider.notifier)
                .setMode(FeedViewMode.classic);
          },
        ),
      ],
    );
  }
}