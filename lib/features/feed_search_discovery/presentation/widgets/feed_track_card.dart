import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';

import '../../domain/entities/feed_item_entity.dart';
import '../../domain/entities/feed_item_source.dart';
import '../providers/feed_notifier.dart';
import 'feed_preview_overlay.dart';
import 'feed_interaction_buttons.dart';
import 'feed_activity_row.dart';
import 'track_info_box.dart';
class FeedTrackCard extends ConsumerWidget {
  final FeedItemEntity item;

  const FeedTrackCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedNotifierProvider);

    final activityText = (item.source == FeedItemSource.repost)
        ? '${item.actor.username} reposted a track'
        : '${item.actor.username} posted a track';

    return GestureDetector(
      onTap: () {
        ref.read(feedNotifierProvider.notifier).togglePreview();
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12.0, 55.0, 12.0, 20.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),

                  const SizedBox(height: 120),

                  Center(
                    child: Container(
                      width: 215.0,
                      height: 215.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: (item.track.coverUrl != null)
                            ? DecorationImage(
                                image: NetworkImage(item.track.coverUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 213),

                  FeedActivityRow(
                    activityText: activityText,
                    avatarUrl: item.actor.avatarUrl,
                    timeAgo: item.timeAgo,
                    createdAt: item.track.createdAt,
                  ),

                  const SizedBox(height: 5.0),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          if (!feedState.isPreviewing) FeedPreviewOverlay(),

          Positioned(
            top: 63.0,
            right: 20.0,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ),

          Positioned(
            top: 470.0,
            right: 20.0,
            child: FeedInteractionButtons(
              isLiked: item.track.interaction.isLiked,
              likesCount: item.track.likesCount,
              commentsCount: item.track.commentsCount,
            ),
          ),

          Positioned(
            left: 20.0,
            right: 20.0,
            bottom: 30.0,
            child: TrackInfoBox(item: item),
          ),
        ],
      ),
    );
  }
}
