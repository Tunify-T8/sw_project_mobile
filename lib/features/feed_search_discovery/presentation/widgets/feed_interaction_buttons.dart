import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/feed_view_mode.dart';
import '../../../engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../engagements_social_interactions/presentation/provider/engagement_state.dart';
import '../../../engagements_social_interactions/presentation/screens/comments_screen.dart';
import '../../../engagements_social_interactions/presentation/widgets/repost_caption_sheet.dart';
import '../../../engagements_social_interactions/presentation/screens/likers_screen.dart';
import '../../../engagements_social_interactions/presentation/screens/reposters_screen.dart';

class FeedInteractionButtons extends ConsumerStatefulWidget {
  final String trackId;
  final int fallbackLikesCount;
  final int fallbackCommentsCount;
  final bool fallbackIsLiked;
  final bool fallbackIsReposted;
  final int fallbackRepostsCount;
  final FeedViewMode feedViewMode;
  final String? coverUrl;
  final String? trackTitle;
  final String? artistName;

  const FeedInteractionButtons({
    super.key,
    required this.trackId,
    required this.fallbackLikesCount,
    required this.fallbackCommentsCount,
    required this.fallbackIsLiked,
    required this.fallbackIsReposted,
    required this.fallbackRepostsCount,
    required this.feedViewMode,
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final state = ref.read(engagementProvider(widget.trackId));
      if (state.engagementStatus == EngagementStatus.initial) {
        ref
            .read(engagementProvider(widget.trackId).notifier)
            .seedFromFeed(
              likeCount: widget.fallbackLikesCount,
              commentCount: widget.fallbackCommentsCount,
              isLiked: widget.fallbackIsLiked,
              isReposted: widget.fallbackIsReposted,
              repostCount: widget.fallbackRepostsCount,
            );
        await ref
            .read(engagementProvider(widget.trackId).notifier)
            .loadEngagement();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(engagementProvider(widget.trackId));
    final isLiked = state.engagement?.isLiked ?? widget.fallbackIsLiked;
    final likesCount = state.engagement?.likeCount ?? widget.fallbackLikesCount;
    final commentsCount =
        state.engagement?.commentCount ?? widget.fallbackCommentsCount;

    final children = [
      IconButton(
        key: const Key('feed_like_button'),
        onPressed: () =>
            ref.read(engagementProvider(widget.trackId).notifier).toggleLike(),
        icon: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : Colors.white,
        ),
        padding: EdgeInsets.zero,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
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
      IconButton(
        key: const Key('feed_comment_button'),
        onPressed: () {
          final currentCommentsCount =
              state.engagement?.commentCount ?? widget.fallbackCommentsCount;
          // ignore: avoid_print
          print(
            '[FeedInteractionButtons] navigating to comments: trackId=${widget.trackId}, commentsCount=$currentCommentsCount',
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CommentsScreen(
                trackId: widget.trackId,
                coverUrl: widget.coverUrl,
                trackTitle: widget.trackTitle,
                artistName: widget.artistName,
              ),
            ),
          );
        },
        icon: const Icon(Icons.comment, color: Colors.white),
        padding: EdgeInsets.zero,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      Text(
        commentsCount.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),

      (widget.feedViewMode == FeedViewMode.discover)
          ? IconButton(
              key: const Key('feed_playlist_add_button'),
              onPressed: () {},
              icon: const Icon(Icons.playlist_add, color: Colors.white),
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                _RepostButton(
                  trackId: widget.trackId,
                  trackTitle: widget.trackTitle ?? '',
                  artistName: widget.artistName ?? '',
                  coverUrl: widget.coverUrl,
                  state: state,
                ),
              ],
            ),
    ];

    return (widget.feedViewMode == FeedViewMode.discover)
        ? Column(children: children)
        : Row(children: children);
  }
}

class _RepostButton extends ConsumerWidget {
  const _RepostButton({
    required this.trackId,
    required this.trackTitle,
    required this.artistName,
    this.coverUrl,
    required this.state,
  });

  final String trackId;
  final String trackTitle;
  final String artistName;
  final String? coverUrl;
  final EngagementState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReposted = state.engagement?.isReposted ?? false;
    final repostCount = state.engagement?.repostCount ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (isReposted) {
              ref.read(engagementProvider(trackId).notifier).removeRepost();
            } else {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: const Color(0xFF121212),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => RepostCaptionSheet(
                  trackId: trackId,
                  trackTitle: trackTitle,
                  artistName: artistName,
                  coverUrl: coverUrl,
                ),
              );
            }
          },
          child: Icon(
            isReposted ? Icons.repeat_on : Icons.repeat,
            color: isReposted ? Colors.orange : Colors.white,
            size: 28,
          ),
        ),
        SizedBox(width: 8,),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RepostersScreen(trackId: trackId),
            ),
          ),
          child: Text(
            repostCount.toString(),
            style: TextStyle(
              color: isReposted ? Colors.orange : Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
