import 'package:flutter/material.dart';

import '../../domain/entities/conversation_entity.dart';
import '../utils/messaging_time_format.dart';

/// A single row in the messages list — avatar, name, preview + timestamp.
/// Matches the SoundCloud Activity > Messages tile layout.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final ConversationEntity conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    final preview = conversation.lastMessagePreview ?? '';
    final timeStr = conversation.lastMessageAt != null
        ? MessagingTimeFormat.relativeShort(conversation.lastMessageAt!)
        : '';

    return InkWell(
      onTap: onTap,
      splashColor: Colors.white10,
      child: Container(
        color: hasUnread ? const Color(0xFF1A1A2E) : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF2196F3).withValues(alpha: 0.3),
                backgroundImage: conversation.otherUser.avatarUrl != null
                    ? NetworkImage(conversation.otherUser.avatarUrl!)
                    : null,
                child: conversation.otherUser.avatarUrl == null
                    ? const Icon(
                        Icons.person,
                        color: Color(0xFF64B5F6),
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Name + preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.otherUser.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: hasUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr.isNotEmpty ? '$preview \u00B7 $timeStr' : preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasUnread
                            ? Colors.white70
                            : const Color(0xFF8A8A8A),
                        fontSize: 13,
                        fontWeight: hasUnread
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
