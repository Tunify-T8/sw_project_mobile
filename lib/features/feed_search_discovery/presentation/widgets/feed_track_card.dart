import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_view_mode.dart';
import '../../domain/entities/feed_tab_type.dart';
import '../../domain/entities/feed_item_entity.dart';
import 'feed_menu_sheet.dart';
import '../providers/feed_notifier.dart';
import '../providers/feed_preview_playback_controller.dart';
import 'feed_preview_overlay.dart';
import 'feed_interaction_buttons.dart';
import 'feed_activity_row.dart';
import 'track_info_box.dart';

class FeedTrackCard extends ConsumerWidget {
  final FeedItemEntity item;
  final FeedType tabType;

  const FeedTrackCard({super.key, required this.item, required this.tabType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedNotifierProvider);

    return GestureDetector(
      onTap: () {
        final wasPreviewing = ref.read(feedNotifierProvider).isPreviewing;
        ref.read(feedNotifierProvider.notifier).togglePreview();

        final previewController = ref.read(
          feedPreviewPlaybackControllerProvider,
        );
        if (wasPreviewing) {
          previewController.stop();
        } else {
          previewController.start(item.track.trackId, item.track.duration);
        }
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
                  const Expanded(flex: 2, child: SizedBox()),

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

                  const Expanded(flex: 2, child: SizedBox()),

                  FeedActivityRow(
                    avatarUrl: item.actor.avatarUrl,
                    timeAgo: item.timeAgo,
                    createdAt: item.track.createdAt,
                    feedViewMode: FeedViewMode.discover,
                    source: item.source,
                    actorName: item.actor.username,
                    trackName: item.track.title,
                  ),

                  const Expanded(flex: 1, child: SizedBox()),
                ],
              ),
            ),
          ),

          if (!feedState.isPreviewing) FeedPreviewOverlay(),

          Positioned(
            top: 63.0,
            right: 20.0,
            child: IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Color(0xFF121212),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  showDragHandle: true,
                  useSafeArea: true,
                  builder: (_) =>
                      FeedMenuSheet(track: item.track, feedViewMode: FeedViewMode.discover),
                );
              },
              icon: const Icon(Icons.more_horiz),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ),

          Positioned(
            bottom: 150.0,
            right: 20.0,
            child: FeedInteractionButtons(
              trackId: item.track.trackId,
              fallbackLikesCount: item.track.likesCount,
              fallbackCommentsCount: item.track.commentsCount,
              feedViewMode: FeedViewMode.discover,
              coverUrl: item.track.coverUrl,
              trackTitle: item.track.title,
              artistName: item.track.artistName,
            ),
          ),

          Positioned(
            left: 20.0,
            right: 20.0,
            bottom: 30.0,
            child: TrackInfoBox(track: item.track),
          ),
        ],
      ),
    );
  }
}
