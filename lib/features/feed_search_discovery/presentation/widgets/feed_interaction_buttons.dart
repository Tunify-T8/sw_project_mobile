import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../engagements_social_interactions/presentation/provider/engagement_state.dart';
import '../../../engagements_social_interactions/presentation/screens/comments_screen.dart';
import '../../../engagements_social_interactions/presentation/screens/likers_screen.dart'; // engagement addition

class FeedInteractionButtons extends ConsumerStatefulWidget { // engagement modification — was StatelessWidget, converted to ConsumerStatefulWidget
  final String trackId; // engagement addition — replaces static isLiked, now drives engagementProvider
  final int fallbackLikesCount;
  final int fallbackCommentsCount;

  const FeedInteractionButtons({
    super.key,
    required this.trackId,
    required this.fallbackLikesCount,
    required this.fallbackCommentsCount,
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
        IconButton(
          onPressed: () => ref
              .read(engagementProvider(widget.trackId).notifier)
              .toggleLike(), // engagement addition — was () {}, now calls toggleLike
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.white,
          ),
          padding: EdgeInsets.zero,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push( // engagement addition — tap like count to open LikersScreen
            MaterialPageRoute(
              builder: (_) => LikersScreen(trackId: widget.trackId),
            ),
          ),
          child: Text(
            likesCount.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).push( // engagement addition — was () {}, now navigates to CommentsScreen
            MaterialPageRoute(
              builder: (_) => CommentsScreen(trackId: widget.trackId),
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
        IconButton(
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
