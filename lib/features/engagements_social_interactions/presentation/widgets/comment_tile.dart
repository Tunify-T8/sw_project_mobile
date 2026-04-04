import 'package:flutter/material.dart';

import '../../domain/entities/comment_entity.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
    this.onTapTimestamp,
    this.onLike,
    this.onReply,
  });

  final CommentEntity comment;
  final ValueChanged<int>? onTapTimestamp;
  final VoidCallback? onLike;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor = Colors.white70;
    final timestamp = comment.timestamp;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            backgroundImage: comment.user.avatarUrl != null
                ? NetworkImage(comment.user.avatarUrl!)
                : null,
            child: comment.user.avatarUrl == null
                ? Text(
                    _initials(comment.user.username),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      comment.user.username,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (timestamp != null)
                      GestureDetector(
                        onTap: onTapTimestamp == null
                            ? null
                            : () => onTapTimestamp!(timestamp),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _formatTimestamp(timestamp),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
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
                Row(
                  children: [
                    TextButton(
                      onPressed: onLike,
                      style: TextButton.styleFrom(
                        foregroundColor: subtitleColor,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Like ${_countText(comment.likesCount)}'),
                    ),
                    TextButton(
                      onPressed: onReply,
                      style: TextButton.styleFrom(
                        foregroundColor: subtitleColor,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Reply ${_countText(comment.repliesCount)}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String username) {
    final clean = username.trim();
    if (clean.isEmpty) return '?';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String _formatTimestamp(int seconds) {
    final safe = seconds < 0 ? 0 : seconds;
    final minutes = safe ~/ 60;
    final remainder = (safe % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  static String _timeAgo(DateTime createdAt) {
    final now = DateTime.now().toUtc();
    final time = createdAt.toUtc();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day}/${time.month}/${time.year}';
  }

  static String _countText(int value) {
    return value <= 0 ? '' : '($value)';
  }
}
