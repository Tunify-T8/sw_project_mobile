import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/reply_entity.dart';
import '../provider/enagement_providers.dart';
import '../utils/engagement_formatters.dart';
import 'comment_like_button.dart';
import 'comment_options_sheet.dart';
import 'reply_tile.dart';

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
  final VoidCallback? onReply;

  @override
  ConsumerState<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<CommentTile> {
  bool _showReplies = false;
  bool _loadingReplies = false;
  List<ReplyEntity> _replies = [];

  Future<void> _toggleReplies() async {
    if (_showReplies) {
      setState(() => _showReplies = false);
      return;
    }
    setState(() => _loadingReplies = true);
    final replies = await ref
        .read(getRepliesUsecaseProvider)
        .call(commentId: widget.comment.id);
    setState(() {
      _replies = replies;
      _showReplies = true;
      _loadingReplies = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comment = widget.comment;
    final timestamp = comment.timestamp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(username: comment.user.username, avatarUrl: comment.user.avatarUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CommentHeader(
                      username: comment.user.username,
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
                        widget.onReply?.call();
                        if (comment.repliesCount > 0) _toggleReplies();
                      },
                      onOptions: () => CommentOptionsSheet.show(
                        context,
                        username: comment.user.username,
                        timestamp: timestamp,
                        onPlayFromTimestamp: timestamp != null && widget.onTapTimestamp != null
                            ? () => widget.onTapTimestamp!(timestamp)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CommentLikeButton(
                trackId: widget.trackId,
                commentId: comment.id,
                baseLikesCount: comment.likesCount,
              ),
            ],
          ),
        ),
        if (_showReplies && _replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Column(
              children: _replies
                  .map((reply) => ReplyTile(reply: reply))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.username, this.avatarUrl});
  final String username;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
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
    );
  }
}

class _CommentHeader extends StatelessWidget {
  const _CommentHeader({
    required this.username,
    required this.timestamp,
    required this.createdAt,
    required this.theme,
    this.onTapTimestamp,
  });

  final String username;
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
        Text(
          username,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            GestureDetector(
              onTap: onReply,
              child: Text(
                repliesCount > 0 ? 'Reply ($repliesCount)' : 'Reply',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
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

