import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../audio_upload_and_management/presentation/utils/track_link_helper.dart';
import '../../../engagements_social_interactions/presentation/screens/comments_screen.dart';
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
    if (notification.type == NotificationType.trackCommented) {
      await openComments(context, ref, notification);
      return;
    }

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
    final fallbackUserId = _referenceUserId(notification);
    final userId = (actorId != null && actorId.trim().isNotEmpty)
        ? actorId.trim()
        : fallbackUserId;

    if (userId == null || userId.trim().isEmpty) {
      _showUnavailable(context);
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OtherUserProfileScreen(userId: userId)),
    );
  }

  static Future<void> openComments(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
  ) async {
    await _markRead(ref, notification);
    if (!context.mounted) return;

    final trackId =
        _trackReferenceId(notification) ??
        await _trackIdByScanningOwnTrackComments(ref, notification);
    if (!context.mounted) return;

    if (trackId == null || trackId.isEmpty) {
      _showMissingTrack(context);
      return;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CommentsScreen(trackId: trackId)));
  }

  static Future<void> openReference(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
  ) async {
    await _markRead(ref, notification);
    if (!context.mounted) return;

    final referenceId = notification.referenceId?.trim();
    final referenceType = _normalizedReferenceType(notification.referenceType);

    if (referenceId == null || referenceId.isEmpty) {
      _showUnavailable(context);
      return;
    }

    if (_isUserReferenceType(referenceType)) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtherUserProfileScreen(userId: referenceId),
        ),
      );
      return;
    }

    if (referenceType == null || _isTrackReferenceType(referenceType)) {
      await TrackLinkHelper.openTrackByIdAndToken(context, ref, referenceId);
      return;
    }

    _showUnavailable(context);
  }

  static String? _trackReferenceId(NotificationEntity notification) {
    final referenceType = _normalizedReferenceType(notification.referenceType);
    final referenceId = notification.referenceId?.trim();
    if (referenceId == null || referenceId.isEmpty) return null;

    if (notification.type == NotificationType.trackCommented) {
      if (referenceType == null || _isTrackReferenceType(referenceType)) {
        return referenceId;
      }
      return null;
    }

    if (referenceType == null || _isTrackReferenceType(referenceType)) {
      return referenceId;
    }

    return null;
  }

  static Future<String?> _trackIdByScanningOwnTrackComments(
    WidgetRef ref,
    NotificationEntity notification,
  ) async {
    final referenceType = _normalizedReferenceType(notification.referenceType);
    if (referenceType != 'comment' && referenceType != 'comments') return null;

    final commentId = notification.referenceId?.trim();
    if (commentId == null || commentId.isEmpty) return null;

    try {
      final dio = ref.read(dioProvider);
      final uploadsResponse = await dio.get(ApiEndpoints.myUploads);
      final trackIds = _trackIdsFromResponse(uploadsResponse.data);

      for (final trackId in trackIds) {
        try {
          final commentsResponse = await dio.get(
            ApiEndpoints.trackComments(trackId),
            queryParameters: const {'page': 1, 'limit': 50},
          );
          if (_commentsContainId(commentsResponse.data, commentId)) {
            return trackId;
          }
        } catch (_) {
          // Keep searching: one private/deleted track should not block the rest.
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String? _referenceUserId(NotificationEntity notification) {
    final referenceType = _normalizedReferenceType(notification.referenceType);
    final referenceId = notification.referenceId?.trim();
    if (referenceId == null || referenceId.isEmpty) return null;

    if (_isUserReferenceType(referenceType) ||
        notification.type == NotificationType.userFollowed) {
      return referenceId;
    }

    return null;
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

  static String? _normalizedReferenceType(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return null;
    return text
        .split('.')
        .last
        .replaceAll('-', '_')
        .replaceAllMapped(
          RegExp(r'(?<=[a-z0-9])[A-Z]'),
          (match) => '_${match.group(0)}',
        )
        .toLowerCase();
  }

  static bool _isTrackReferenceType(String? referenceType) {
    return referenceType == 'track' ||
        referenceType == 'tracks' ||
        referenceType == 'song' ||
        referenceType == 'audio' ||
        referenceType == 'upload';
  }

  static bool _isUserReferenceType(String? referenceType) {
    return referenceType == 'user' || referenceType == 'users';
  }

  static List<String> _trackIdsFromResponse(Object? raw) {
    final list = _firstList(raw, const ['items', 'tracks', 'uploads', 'data']);
    final ids = <String>[];
    for (final item in list) {
      if (item is! Map) continue;
      final map = item.map((key, value) => MapEntry(key.toString(), value));
      final id = _stringOrNull(map['trackId'] ?? map['id'] ?? map['_id']);
      if (id != null) ids.add(id);
    }
    return ids;
  }

  static bool _commentsContainId(Object? raw, String commentId) {
    final comments = _firstList(raw, const ['comments', 'data', 'items']);
    for (final comment in comments) {
      if (comment is! Map) continue;
      final map = comment.map((key, value) => MapEntry(key.toString(), value));
      final id = _stringOrNull(map['commentId'] ?? map['id'] ?? map['_id']);
      if (id == commentId) return true;
    }
    return false;
  }

  static List<dynamic> _firstList(Object? raw, List<String> keys) {
    if (raw is List) return raw;
    if (raw is! Map) return const [];

    final map = raw.map((key, value) => MapEntry(key.toString(), value));
    for (final key in keys) {
      final value = map[key];
      if (value is List) return value;
    }

    for (final key in keys) {
      final nested = map[key];
      final nestedList = _firstList(nested, keys);
      if (nestedList.isNotEmpty) return nestedList;
    }

    return const [];
  }

  static String? _stringOrNull(Object? raw) {
    final text = raw?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static void _showUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This notification target is not available anymore.'),
        backgroundColor: Color(0xFF2A2A2A),
      ),
    );
  }

  static void _showMissingTrack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This comment notification is missing its track target.'),
        backgroundColor: Color(0xFF2A2A2A),
      ),
    );
  }
}
