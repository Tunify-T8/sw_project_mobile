import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/presentation/utils/track_link_helper.dart';
import '../../../profile/presentation/screens/other_user_profile_screen.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_type.dart';
import '../state/notifications_controller.dart';

class NotificationNavigation {
  NotificationNavigation._();

  static Future<void> openDefault(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
  ) async {
    if (_isTrackNotification(notification)) {
      await openReference(context, ref, notification);
      return;
    }

    await openActor(context, ref, notification);
  }

  static Future<void> openActor(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
  ) async {
    await _markRead(ref, notification);
    if (!context.mounted) return;

    final actorId = notification.actor?.id;
    if (actorId == null || actorId.trim().isEmpty) {
      _showUnavailable(context);
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtherUserProfileScreen(userId: actorId),
      ),
    );
  }

  static Future<void> openReference(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
  ) async {
    await _markRead(ref, notification);
    if (!context.mounted) return;

    final referenceId = notification.referenceId?.trim();
    final referenceType = notification.referenceType?.toLowerCase().trim();

    if (referenceId == null || referenceId.isEmpty) {
      _showUnavailable(context);
      return;
    }

    if (referenceType == 'user') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtherUserProfileScreen(userId: referenceId),
        ),
      );
      return;
    }

    if (referenceType == null || referenceType == 'track') {
      await TrackLinkHelper.openTrackByIdAndToken(context, ref, referenceId);
      return;
    }

    _showUnavailable(context);
  }

  static Future<void> _markRead(
    WidgetRef ref,
    NotificationEntity notification,
  ) async {
    if (notification.isRead) return;
    await ref
        .read(notificationsControllerProvider.notifier)
        .markAsRead(notification.id);
  }

  static bool _isTrackNotification(NotificationEntity notification) {
    return notification.type == NotificationType.trackLiked ||
        notification.type == NotificationType.trackCommented ||
        notification.type == NotificationType.trackReposted ||
        notification.type == NotificationType.newRelease;
  }

  static void _showUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This notification target is not available anymore.'),
        backgroundColor: Color(0xFF2A2A2A),
      ),
    );
  }
}
