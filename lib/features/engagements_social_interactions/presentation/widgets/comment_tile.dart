import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/reply_entity.dart';
import '../provider/enagement_providers.dart';
import '../utils/engagement_formatters.dart';
import 'comment_like_button.dart';
import 'comment_options_sheet.dart';
import 'reply_tile.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class CommentTile extends ConsumerStatefulWidget {
  const CommentTile({
    super.key,
    required this.comment,
    required this.trackId,
    this.onTapTimestamp,
    this.onReply,
  });

  final CommentEntity comment;
  final String trackId;
  final ValueChanged<int>? onTapTimestamp;
  final ValueChanged<String>? onReply; // receives username to pre-fill @mention in input

  @override
  ConsumerState<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<CommentTile> {
  bool _showReplies = false;
  bool _loadingReplies = false;
  List<ReplyEntity> _replies = [];

  @override
  void initState() {
    super.initState();
    // engagement addition — auto-load replies if the comment already has some
    if (widget.comment.repliesCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadReplies());
    }
  }

  @override
  void didUpdateWidget(CommentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // engagement addition — reload if repliesCount changed (reply added or deleted)
    if (widget.comment.repliesCount != oldWidget.comment.repliesCount &&
        widget.comment.repliesCount > 0) {
      _loadReplies();
    }
  }

  Future<void> _loadReplies() async {
    setState(() => _loadingReplies = true);
    final replies = await ref
        .read(getRepliesUsecaseProvider)
        .call(commentId: widget.comment.id);
    if (mounted) {
      ref.read(engagementProvider(widget.trackId).notifier).seedReplyLikes(replies);
      setState(() {
        _replies = replies;
        _showReplies = replies.isNotEmpty;
        _loadingReplies = false;
      });
    }
  }

  Future<void> _toggleReplies() async {
    if (_showReplies) {
      setState(() => _showReplies = false);
      return;
    }
    await _loadReplies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comment = widget.comment;
    final timestamp = comment.timestamp;
    final currentUserId = ref.read(authControllerProvider).value?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(
                username: comment.user.displayName,
                avatarUrl: comment.user.avatarUrl,
                userId: comment.user.id,
                currentUserId: currentUserId,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CommentHeader(
                      username: comment.user.displayName,
                      isCertified: comment.user.isCertified,
                      userId: comment.user.id,
                      currentUserId: currentUserId,
                      timestamp: timestamp,
                      createdAt: comment.createdAt,
                      onTapTimestamp: widget.onTapTimestamp,
                      theme: theme,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CommentActions(
                      repliesCount: comment.repliesCount,
                      loadingReplies: _loadingReplies,
                      onReply: () {
                        widget.onReply?.call(comment.user.displayName);
                        if (comment.repliesCount > 0) _toggleReplies();
                      },
                      onOptions: () => CommentOptionsSheet.show(
                        context,
                        username: comment.user.displayName,
                        timestamp: timestamp,
                        onPlayFromTimestamp: timestamp != null && widget.onTapTimestamp != null
                            ? () => widget.onTapTimestamp!(timestamp)
                            : null,
                        isOwner: comment.user.id ==
                            (ref.read(authControllerProvider).value?.id ?? ''),
                        onDelete: () async {
                          await ref
                              .read(engagementProvider(widget.trackId).notifier)
                              .deleteComment(comment.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CommentLikeButton(
                trackId: widget.trackId,
                commentId: comment.id,
                baseLikesCount: comment.likesCount - (comment.isLiked ? 1 : 0),
              ),
            ],
          ),
        ),
        if (_showReplies && _replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Column(
              children: _replies
                  .map((reply) => ReplyTile(
                        reply: reply,
                        trackId: widget.trackId,
                        parentTimestamp: comment.timestamp,
                        onReply: () => widget.onReply?.call(reply.user.displayName),
                        onDelete: () async {
                          await ref.read(deleteReplyUsecaseProvider).call(
                                commentId: comment.id,
                                replyId: reply.id,
                              );
                          await _loadReplies();
                        },
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.username,
    this.avatarUrl,
    required this.userId,
    this.currentUserId,
  });
  final String username;
  final String? avatarUrl;
  final String userId;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateToProfile(context, userId, currentUserId: currentUserId),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white24,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        child: avatarUrl == null
            ? Text(
                EngagementFormatters.initials(username),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
    );
  }
}

class _CommentHeader extends StatelessWidget {
  const _CommentHeader({
    required this.username,
    required this.isCertified,
    required this.userId,
    required this.currentUserId,
    required this.timestamp,
    required this.createdAt,
    required this.theme,
    this.onTapTimestamp,
  });

  final String username;
  final bool isCertified;
  final String userId;
  final String? currentUserId;
  final int? timestamp;
  final DateTime createdAt;
  final ThemeData theme;
  final ValueChanged<int>? onTapTimestamp;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        GestureDetector(
          onTap: () => navigateToProfile(context, userId, currentUserId: currentUserId),
          child: Text(
            username,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (isCertified)
          const Icon(Icons.verified, color: Colors.blue, size: 14),
        if (timestamp != null)
          GestureDetector(
            onTap: onTapTimestamp == null
                ? null
                : () => onTapTimestamp!(timestamp!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                EngagementFormatters.timestamp(timestamp!),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        Text(
          EngagementFormatters.timeAgo(createdAt),
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white54),
        ),
      ],
    );
  }
}

class _CommentActions extends StatelessWidget {
  const _CommentActions({
    required this.repliesCount,
    required this.loadingReplies,
    required this.onReply,
    required this.onOptions,
  });

  final int repliesCount;
  final bool loadingReplies;
  final VoidCallback onReply;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Key: EngagementKeys.commentReplyButton
            GestureDetector(
              key: const Key('comment_reply_button'),
              onTap: onReply,
              child: const Text(
                'Reply',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
            const SizedBox(width: 16),
            // Key: EngagementKeys.commentOptionsButton
            GestureDetector(
              key: const Key('comment_options_button'),
              onTap: onOptions,
              child: const Icon(Icons.more_vert, color: Colors.white54, size: 18),
            ),
          ],
        ),
        if (loadingReplies)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

