import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/feed_tab_type.dart';
import '../../../engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../engagements_social_interactions/presentation/provider/engagement_state.dart';
import '../../../engagements_social_interactions/presentation/screens/comments_screen.dart';
import '../../../engagements_social_interactions/presentation/screens/likers_screen.dart';
import '../../../engagements_social_interactions/presentation/widgets/repost_caption_sheet.dart';

class FeedInteractionButtons extends ConsumerStatefulWidget {
  final String trackId;
  final int fallbackLikesCount;
  final int fallbackCommentsCount;
  final FeedType feedType;
  final String? coverUrl;
  final String? trackTitle;
  final String? artistName;

  const FeedInteractionButtons({
    super.key,
    required this.trackId,
    required this.fallbackLikesCount,
    required this.fallbackCommentsCount,
    required this.feedType,
    this.coverUrl,
    this.trackTitle,
    this.artistName,
  });

  @override
  ConsumerState<FeedInteractionButtons> createState() =>
      _FeedInteractionButtonsState();
}

class _FeedInteractionButtonsState
    extends ConsumerState<FeedInteractionButtons> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(engagementProvider(widget.trackId));
      if (state.engagementStatus == EngagementStatus.initial) {
        ref
            .read(engagementProvider(widget.trackId).notifier)
            .loadEngagement(); // engagement addition — fetch engagement data when card first appears
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(engagementProvider(widget.trackId));
    final isLiked = state.engagement?.isLiked ?? false;
    final likesCount =
        state.engagement?.likeCount ?? widget.fallbackLikesCount;
    final commentsCount =
        state.engagement?.commentCount ?? widget.fallbackCommentsCount;

    return Column(
      children: [
        // Key: FeedKeys.likeButton
        IconButton(
          key: const Key('feed_like_button'),
          onPressed: () => ref
              .read(engagementProvider(widget.trackId).notifier)
              .toggleLike(),
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.white,
          ),
          padding: EdgeInsets.zero,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        // Key: FeedKeys.likesCount
        GestureDetector(
          key: const Key('feed_likes_count'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LikersScreen(trackId: widget.trackId),
            ),
          ),
          child: Text(
            likesCount.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
        // Key: FeedKeys.commentButton
        IconButton(
          key: const Key('feed_comment_button'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CommentsScreen(
                trackId: widget.trackId,
                coverUrl: widget.coverUrl,
                trackTitle: widget.trackTitle,
                artistName: widget.artistName,
              ),
            ),
          ),
          icon: const Icon(Icons.comment, color: Colors.white),
          padding: EdgeInsets.zero,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        Text(
          commentsCount.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        // Key: FeedKeys.playlistAddButton
        IconButton(
          key: const Key('feed_playlist_add_button'),
          onPressed: () {},
          icon: const Icon(Icons.playlist_add, color: Colors.white),
          padding: EdgeInsets.zero,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ],
    );
  }
}
