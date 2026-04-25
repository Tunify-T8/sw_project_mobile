import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/feed_view_mode.dart';

import '../../domain/entities/feed_item_entity.dart';
import 'feed_activity_row.dart';
import 'feed_interaction_buttons.dart';
import '../../../../../core/utils/navigation_utils.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../widgets/feed_menu_sheet.dart';

class ClassicFeedCard extends ConsumerWidget {
  final FeedItemEntity item;

  const ClassicFeedCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => navigateToProfile(
              context,
              item.actor.id,
              currentUserId: ref.read(authControllerProvider).value?.id,
            ),
            child: FeedActivityRow(
              avatarUrl: item.actor.avatarUrl,
              timeAgo: item.timeAgo,
              feedViewMode: FeedViewMode.classic,
              source: item.source,
              actorName: item.actor.username,
              trackName: item.track.title,
            ),
          ),
          const SizedBox(height: 16),

          Stack(
            children: [
              GestureDetector(
                onTap: () {}, //play track here. only starts doesnt stop
                child: Container(
                  width: double.infinity,
                  height: 350,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(8),
                    image: item.track.coverUrl != null
                        ? DecorationImage(
                            image: NetworkImage(item.track.coverUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.track.coverUrl == null
                      ? const Center(
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white24,
                            size: 56,
                          ),
                        )
                      : null,
                ),
              ),

              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.black),
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      child: Text(
                        item.track.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.black),
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      child: GestureDetector(
                        onTap: () => navigateToProfile(
                          context,
                          item.track.artistId,
                          currentUserId: ref.read(authControllerProvider).value?.id,
                        ),
                        child: Text(
                          item.track.artistName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.black),
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.track.listensCount} • ${Duration(seconds: item.track.duration).toString().substring(2, 7)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              FeedInteractionButtons(
                trackId: item.track.trackId,
                fallbackLikesCount: item.track.likesCount,
                fallbackCommentsCount: item.track.commentsCount,
                fallbackIsLiked: item.track.interaction.isLiked,
                fallbackIsReposted: item.track.interaction.isReposted,
                fallbackRepostsCount: item.track.repostsCount,
                feedViewMode: FeedViewMode.classic,
                coverUrl: item.track.coverUrl,
                trackTitle: item.track.title,
                artistName: item.track.artistName,
              ),
              const Spacer(),
              IconButton(
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
                    builder: (_) => FeedMenuSheet(
                      track: item.track,
                      feedViewMode: FeedViewMode.classic,
                    ),
                  );
                },
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
