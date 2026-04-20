import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reply_entity.dart';
import '../provider/enagement_providers.dart';
import '../utils/engagement_formatters.dart';
import 'comment_options_sheet.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class ReplyTile extends ConsumerStatefulWidget { // engagement modification — was StatefulWidget, converted to ConsumerStatefulWidget to call toggleReplyLike use case
  const ReplyTile({
    super.key,
    required this.reply,
    this.parentTimestamp,
    this.onReply,
    this.onDelete,
  });

  final ReplyEntity reply;
  final int? parentTimestamp;   // timestamp of the parent comment passed for "Play from X:XX" in options
  final VoidCallback? onReply;
  final VoidCallback? onDelete;

  @override
  ConsumerState<ReplyTile> createState() => _ReplyTileState();
}

class _ReplyTileState extends ConsumerState<ReplyTile> {
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    // engagement addition — initialize from entity so like state survives navigation
    _isLiked = widget.reply.isLikedByViewer;
    _likesCount = widget.reply.likesCount;
  }

  @override
  void didUpdateWidget(ReplyTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // engagement addition — sync if the entity is replaced (e.g. parent reloads replies)
    if (widget.reply.id == oldWidget.reply.id &&
        widget.reply.isLikedByViewer != oldWidget.reply.isLikedByViewer) {
      _isLiked = widget.reply.isLikedByViewer;
      _likesCount = widget.reply.likesCount;
    }
  }

  Future<void> _toggleLike() async {
    // engagement addition — optimistic update first, then persist in store via use case
    setState(() {
      _isLiked = !_isLiked;
      _likesCount = _isLiked ? _likesCount + 1 : (_likesCount - 1).clamp(0, 999999);
    });
    try {
      await ref.read(toggleReplyLikeUsecaseProvider).call(
            commentId: widget.reply.commentId,
            replyId: widget.reply.id,
            viewerId: ref.read(authControllerProvider).value?.id ?? '',
          );
    } catch (_) {
      // revert on failure
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likesCount = _isLiked ? _likesCount + 1 : (_likesCount - 1).clamp(0, 999999);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reply = widget.reply;

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
                    reply.user.username.isNotEmpty
                        ? reply.user.username[0].toUpperCase()
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
                      reply.user.username,
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
                    GestureDetector(
                      onTap: widget.onReply,
                      child: const Text(
                        'Reply',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => CommentOptionsSheet.show(
                        context,
                        username: reply.user.username,
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
          GestureDetector(
            onTap: _toggleLike, // engagement modification — was local setState, now persists via use case
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.orangeAccent : Colors.white54,
                  size: 18,
                ),
                if (_likesCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    _likesCount.toString(),
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
