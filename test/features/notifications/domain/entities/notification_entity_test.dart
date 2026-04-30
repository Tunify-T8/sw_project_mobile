import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/notifications/domain/entities/notification_entity.dart';
import 'package:software_project/features/notifications/domain/entities/notification_actor.dart';
import 'package:software_project/features/notifications/domain/entities/notification_type.dart';

void main() {
  group('NotificationEntity', () {
    test('creates notification with required fields', () {
      final now = DateTime.now();
      final notification = NotificationEntity(
        id: 'notif-1',
        type: NotificationType.like,
        message: 'Someone liked your track',
        createdAt: now,
      );

      expect(notification.id, 'notif-1');
      expect(notification.type, NotificationType.like);
      expect(notification.message, 'Someone liked your track');
      expect(notification.createdAt, now);
      expect(notification.isRead, false);
    });

    test('includes actor information', () {
      final actor = const NotificationActor(
        id: 'user-1',
        username: 'john_doe',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final notification = NotificationEntity(
        id: 'notif-1',
        type: NotificationType.like,
        actor: actor,
        message: 'john_doe liked your track',
        createdAt: DateTime.now(),
      );

      expect(notification.actor, actor);
      expect(notification.actor?.username, 'john_doe');
    });

    test('tracks reference information', () {
      final notification = NotificationEntity(
        id: 'notif-1',
        type: NotificationType.like,
        referenceType: 'track',
        referenceId: 'track-123',
        message: 'Someone liked your track',
        createdAt: DateTime.now(),
      );

      expect(notification.referenceType, 'track');
      expect(notification.referenceId, 'track-123');
    });

    test('marks as read with timestamp', () {
      final now = DateTime.now();
      final readAt = now.add(const Duration(seconds: 10));

      final notification = NotificationEntity(
        id: 'notif-1',
        type: NotificationType.like,
        message: 'Someone liked your track',
        createdAt: now,
        isRead: true,
        readAt: readAt,
      );

      expect(notification.isRead, true);
      expect(notification.readAt, readAt);
    });

    test('copyWith updates specific fields', () {
      final now = DateTime.now();
      final notification = NotificationEntity(
        id: 'notif-1',
        type: NotificationType.like,
        message: 'Someone liked your track',
        createdAt: now,
        isRead: false,
      );

      final readAt = now.add(const Duration(seconds: 5));
      final updated = notification.copyWith(
        isRead: true,
        readAt: readAt,
      );

      expect(updated.isRead, true);
      expect(updated.readAt, readAt);
      expect(updated.id, 'notif-1'); // Preserved
      expect(updated.message, 'Someone liked your track'); // Preserved
    });

    test('copyWith preserves original when not specified', () {
      final now = DateTime.now();
      const actor = NotificationActor(
        id: 'user-1',
        username: 'john_doe',
      );

      final notification = NotificationEntity(
        id: 'notif-1',
        type: NotificationType.like,
        actor: actor,
        referenceType: 'track',
        message: 'Someone liked your track',
        createdAt: now,
      );

      final updated = notification.copyWith(isRead: true);

      expect(updated.actor, actor);
      expect(updated.referenceType, 'track');
      expect(updated.message, 'Someone liked your track');
    });

    test('supports multiple notification types', () {
      final types = [
        NotificationType.like,
        NotificationType.follow,
        NotificationType.comment,
        NotificationType.repost,
      ];

      for (final type in types) {
        final notification = NotificationEntity(
          id: 'notif-1',
          type: type,
          message: 'Notification message',
          createdAt: DateTime.now(),
        );

        expect(notification.type, type);
      }
    });

    test('handles null actor gracefully', () {
      final notification = NotificationEntity(
        id: 'notif-1',
        type: NotificationType.like,
        actor: null,
        message: 'Someone liked your track',
        createdAt: DateTime.now(),
      );

      expect(notification.actor, isNull);
    });

    test('handles null reference information', () {
      final notification = NotificationEntity(
        id: 'notif-1',
        type: NotificationType.like,
        referenceType: null,
        referenceId: null,
        message: 'Someone liked your track',
        createdAt: DateTime.now(),
      );

      expect(notification.referenceType, isNull);
      expect(notification.referenceId, isNull);
    });
  });

  group('NotificationActor', () {
    test('creates actor with required fields', () {
      const actor = NotificationActor(
        id: 'user-1',
        username: 'john_doe',
      );

      expect(actor.id, 'user-1');
      expect(actor.username, 'john_doe');
      expect(actor.avatarUrl, isNull);
    });

    test('includes optional avatar URL', () {
      const actor = NotificationActor(
        id: 'user-1',
        username: 'john_doe',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      expect(actor.avatarUrl, 'https://example.com/avatar.jpg');
    });
  });

  group('NotificationType', () {
    test('has all notification types', () {
      final types = [
        NotificationType.like,
        NotificationType.follow,
        NotificationType.comment,
        NotificationType.repost,
        NotificationType.message,
        NotificationType.system,
      ];

      for (final type in types) {
        expect(type, isNotNull);
      }
    });
  });
}
