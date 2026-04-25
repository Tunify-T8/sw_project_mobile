import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reply_entity.dart';
import '../provider/enagement_providers.dart';
import '../utils/engagement_formatters.dart';
import 'comment_options_sheet.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class ReplyTile extends ConsumerStatefulWidget {
  const ReplyTile({
    super.key,
    required this.reply,
    required this.trackId,
    this.parentTimestamp,
    this.onReply,
    this.onDelete,
  });

  final ReplyEntity reply;
  final String trackId;
  final int? parentTimestamp;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;

  @override
  ConsumerState<ReplyTile> createState() => _ReplyTileState();
}

class _ReplyTileState extends ConsumerState<ReplyTile> {
  Future<void> _toggleLike() async {
    await ref
        .read(engagementProvider(widget.trackId).notifier)
        .toggleReplyLike(commentId: widget.reply.commentId, replyId: widget.reply.id);
  }

  @override
  Widget build(BuildContext context) {
    final reply = widget.reply;
    final _isLiked = ref.watch(engagementProvider(widget.trackId)).isReplyLiked(reply.id);
    final likeCount = reply.likesCount + (_isLiked ? 1 : 0) - (reply.isLikedByViewer ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white24,
            backgroundImage: reply.user.avatarUrl != null
                ? NetworkImage(reply.user.avatarUrl!)
                : null,
            child: reply.user.avatarUrl == null
                ? Text(
                    reply.user.displayName.isNotEmpty
                        ? reply.user.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.user.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      EngagementFormatters.timeAgo(reply.createdAt),
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reply.parentUsername != null
                      ? '@${reply.parentUsername} ${reply.text}'
                      : reply.text,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Key: EngagementKeys.replyTileReplyButton
                    GestureDetector(
                      key: const Key('reply_tile_reply_button'),
                      onTap: widget.onReply,
                      child: const Text(
                        'Reply',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Key: EngagementKeys.replyOptionsButton
                    GestureDetector(
                      key: const Key('reply_options_button'),
                      onTap: () => CommentOptionsSheet.show(
                        context,
                        username: reply.user.displayName,
                        timestamp: widget.parentTimestamp,
                        isOwner: reply.user.id ==
                            (ref.read(authControllerProvider).value?.id ?? ''),
                        onDelete: widget.onDelete,
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Key: EngagementKeys.replyTileLikeButton (ValueKey per reply)
          GestureDetector(
            key: ValueKey('reply_tile_like_button_${widget.reply.id}'),
            onTap: _toggleLike, // engagement modification — was local setState, now persists via use case
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.orangeAccent : Colors.white54,
                  size: 18,
                ),
                if (likeCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    likeCount.toString(),
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
