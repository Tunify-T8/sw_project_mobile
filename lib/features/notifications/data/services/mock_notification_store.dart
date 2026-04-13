import 'dart:async';

import '../dto/notification_dto.dart';
import 'push_notification_service.dart';

/// In-memory notification store used by the mock repository.
/// Shared across screens via a Riverpod provider so state is consistent.
class MockNotificationStore {
  final List<NotificationDto> notifications = [];
  final Map<String, bool> pushPreferences = {
    'trackLiked': true,
    'trackCommented': true,
    'trackReposted': true,
    'userFollowed': true,
    'newRelease': true,
    'newMessage': true,
    'system': true,
    'subscription': true,
  };
  final Map<String, bool> emailPreferences = {
    'trackLiked': true,
    'trackCommented': true,
    'trackReposted': true,
    'userFollowed': true,
    'newRelease': true,
    'newMessage': true,
    'system': true,
    'subscription': true,
  };

  final _newNotificationController =
      StreamController<NotificationDto>.broadcast();

  Stream<NotificationDto> get onNewNotification =>
      _newNotificationController.stream;

  bool _seeded = false;

  void seedIfNeeded() {
    if (_seeded) return;
    _seeded = true;

    final now = DateTime.now();

    notifications.addAll([
      NotificationDto(
        id: 'notif-001',
        type: 'track_commented',
        actor: const NotificationActorDto(
          id: 'user-rozana',
          username: 'Rozana Ahmed',
        ),
        referenceType: 'comment',
        referenceId: 'comment-001',
        message: 'commented yes on Win The Morning WIN THE DAY! Listen Every Day! MORNING MOTIVATION',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 23)),
      ),
      NotificationDto(
        id: 'notif-002',
        type: 'track_liked',
        actor: const NotificationActorDto(
          id: 'user-rozana',
          username: 'Rozana Ahmed',
        ),
        referenceType: 'track',
        referenceId: 'track-001',
        message: 'liked your track Win The Morning WIN THE DAY! Listen Every Day! MORNING MOTIVATION',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 23)),
      ),
      NotificationDto(
        id: 'notif-003',
        type: 'user_followed',
        actor: const NotificationActorDto(
          id: 'user-ahmed',
          username: 'Ahmed Hassan',
        ),
        referenceType: 'user',
        referenceId: 'user-ahmed',
        message: 'started following you',
        isRead: true,
        readAt: now.subtract(const Duration(hours: 10)),
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
      ),
      NotificationDto(
        id: 'notif-004',
        type: 'track_reposted',
        actor: const NotificationActorDto(
          id: 'user-sara',
          username: 'Sara Music',
        ),
        referenceType: 'track',
        referenceId: 'track-002',
        message: 'reposted your track Chill Beats Vol. 3',
        isRead: true,
        readAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      NotificationDto(
        id: 'notif-005',
        type: 'track_liked',
        actor: const NotificationActorDto(
          id: 'user-omar',
          username: 'Omar Beats',
        ),
        referenceType: 'track',
        referenceId: 'track-003',
        message: 'liked your track Late Night Vibes',
        isRead: true,
        readAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      NotificationDto(
        id: 'notif-006',
        type: 'track_commented',
        actor: const NotificationActorDto(
          id: 'user-lina',
          username: 'Lina K.',
        ),
        referenceType: 'comment',
        referenceId: 'comment-002',
        message: 'commented fire on Late Night Vibes',
        isRead: true,
        readAt: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      NotificationDto(
        id: 'notif-007',
        type: 'user_followed',
        actor: const NotificationActorDto(
          id: 'user-karim',
          username: 'Karim Adel',
        ),
        referenceType: 'user',
        referenceId: 'user-karim',
        message: 'started following you',
        isRead: true,
        readAt: now.subtract(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }

  void addNotification(NotificationDto dto) {
    notifications.insert(0, dto);
    _newNotificationController.add(dto);

    // Fire a device-level push notification so it appears in the system tray.
    final actorName = dto.actor?.username ?? 'Tunify';
    PushNotificationService.instance.show(
      id: dto.id.hashCode,
      title: actorName,
      body: dto.message,
      payload: dto.id,
    );
  }

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  void dispose() {
    _newNotificationController.close();
  }
}
