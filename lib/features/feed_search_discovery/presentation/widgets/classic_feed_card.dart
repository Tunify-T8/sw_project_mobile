import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/feed_item_entity.dart';
import '../../domain/entities/feed_tab_type.dart';
import 'feed_activity_row.dart';
import 'feed_interaction_buttons.dart';
import 'package:software_project/features/profile/presentation/screens/other_user_profile_screen.dart';

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
          FeedActivityRow(
            avatarUrl: item.actor.avatarUrl,
            timeAgo: item.timeAgo,
            feedType: FeedType.classic,
            source: item.source,
            actorName: item.actor.username,
            trackName: item.track.title,
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
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

          const SizedBox(height: 12),

          Text(
            item.track.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtherUserProfileScreen(userId: item.track.artistId),
              ),
            ),
            child: Text(
              item.track.artistName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.track.listensCount}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const Text(
                ' · ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Text(
                '${item.track.duration}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              FeedInteractionButtons(
                isLiked: item.track.interaction.isLiked,
                isReposted: item.track.interaction.isReposted,
                likesCount: item.track.likesCount,
                repostsCount: item.track.repostsCount,
                commentsCount: item.track.commentsCount,
                feedType: FeedType.classic,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
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