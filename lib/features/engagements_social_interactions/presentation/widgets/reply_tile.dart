import 'package:flutter/material.dart';

import '../../domain/entities/reply_entity.dart';
import '../utils/engagement_formatters.dart';

class ReplyTile extends StatelessWidget {
  const ReplyTile({super.key, required this.reply});

  final ReplyEntity reply;

  @override
  Widget build(BuildContext context) {
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
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
