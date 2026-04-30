import 'package:flutter/material.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_type.dart';
import '../utils/time_ago.dart';

/// A single notification row matching the SoundCloud notification UI.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    this.onActorTap,
    this.onReferenceTap,
    this.onActionTap,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback? onActorTap;
  final VoidCallback? onReferenceTap;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : const Color(0xFF1A1A2E),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──
            _buildAvatar(),
            const SizedBox(width: 12),

            // ── Content ──
            Expanded(child: _buildContent()),

            const SizedBox(width: 8),

            // ── Action icon on the right ──
            _buildActionIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final actor = notification.actor;
    final avatar = actor != null && actor.avatarUrl != null
        ? CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(actor.avatarUrl!),
            backgroundColor: const Color(0xFF2A2A2A),
          )
        : const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF3A3A5A),
            child: Icon(Icons.person, color: Colors.white70, size: 22),
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onActorTap,
      child: avatar,
    );
  }

  Widget _buildContent() {
    final actor = notification.actor;
    final actorName = actor?.username ?? '';
    final ago = timeAgo(notification.createdAt);

    // Split the message to highlight the track/entity name.
    // The message format from the API is like:
    //   "liked your track Some Track Name"
    //   "commented hello on Some Track Name"
    //   "started following you"
    final message = notification.message;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username + time
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onActorTap,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: actorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: '  $ago',
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 3),

        // Notification message with highlighted entity name
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onReferenceTap,
          child: _buildMessageText(message),
        ),

        // Like button for comment notifications
        if (notification.type == NotificationType.trackCommented)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, color: Colors.white70, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Like',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageText(String message) {
    // Try to find the track/entity name after keywords.
    final patterns = ['your track ', ' on '];

    for (final pattern in patterns) {
      final idx = message.indexOf(pattern);
      if (idx != -1) {
        final actionPart = message.substring(0, idx + pattern.length);
        final entityPart = message.substring(idx + pattern.length);

        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: actionPart,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              TextSpan(
                text: entityPart,
                style: const TextStyle(
                  color: Color(0xFF4A90D9),
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      }
    }

    // Fallback: plain text.
    return Text(
      message,
      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
    );
  }

  Widget _buildActionIcon() {
    // Follow-back button for user_followed notifications.
    if (notification.type == NotificationType.userFollowed) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onActionTap ?? onActorTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF3366FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    // User icon for track interactions.
    if (notification.type == NotificationType.trackLiked ||
        notification.type == NotificationType.trackCommented ||
        notification.type == NotificationType.trackReposted) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onActionTap ?? onActorTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF3366FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
