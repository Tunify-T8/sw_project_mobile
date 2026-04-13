import 'dart:async';

import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/entities/paginated_notifications.dart';
import '../../domain/repositories/notification_repository.dart';
import '../dto/notification_dto.dart';
import '../mappers/notification_mapper.dart';
import '../services/mock_notification_store.dart';

/// Mock repo — all state lives in [MockNotificationStore].
/// Mirrors [RealNotificationRepository] so providers can swap transparently.
class MockNotificationRepository implements NotificationRepository {
  final MockNotificationStore _store;

  MockNotificationRepository(this._store) {
    _store.seedIfNeeded();
  }

  @override
  Future<PaginatedNotifications> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  }) async {
    var items = List<NotificationDto>.from(_store.notifications);

    // Filter by type (comma-separated).
    if (type != null && type.isNotEmpty) {
      final types = type.split(',').map((t) => t.trim()).toSet();
      items = items.where((n) => types.contains(n.type)).toList();
    }

    // Filter by unread.
    if (unreadOnly == true) {
      items = items.where((n) => !n.isRead).toList();
    }

    // Sort newest first.
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return PaginatedNotifications(
      items: items.map(NotificationMapper.notification).toList(),
      page: page,
      limit: limit,
      total: items.length,
      unreadCount: _store.unreadCount,
    );
  }

  @override
  Future<int> getUnreadCount() async => _store.unreadCount;

  @override
  Future<void> markAsRead(String notificationId) async {
    final index =
        _store.notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final old = _store.notifications[index];
    if (old.isRead) return;

    _store.notifications[index] = NotificationDto(
      id: old.id,
      type: old.type,
      actor: old.actor,
      referenceType: old.referenceType,
      referenceId: old.referenceId,
      message: old.message,
      isRead: true,
      readAt: DateTime.now(),
      createdAt: old.createdAt,
    );
  }

  @override
  Future<int> markAllAsRead() async {
    int count = 0;
    for (int i = 0; i < _store.notifications.length; i++) {
      final old = _store.notifications[i];
      if (!old.isRead) {
        _store.notifications[i] = NotificationDto(
          id: old.id,
          type: old.type,
          actor: old.actor,
          referenceType: old.referenceType,
          referenceId: old.referenceId,
          message: old.message,
          isRead: true,
          readAt: DateTime.now(),
          createdAt: old.createdAt,
        );
        count++;
      }
    }
    return count;
  }

  @override
  Future<NotificationPreferencesEntity> getPreferences() async =>
      NotificationPreferencesEntity(
        push: _channelFromMap(_store.pushPreferences),
        email: _channelFromMap(_store.emailPreferences),
      );

  @override
  Future<void> updatePreferences({
    Map<String, bool>? push,
    Map<String, bool>? email,
  }) async {
    if (push != null) {
      _store.pushPreferences.addAll(push);
    }
    if (email != null) {
      _store.emailPreferences.addAll(email);
    }
  }

  PreferenceChannel _channelFromMap(Map<String, bool> map) =>
      PreferenceChannel(
        trackLiked: map['trackLiked'] ?? true,
        trackCommented: map['trackCommented'] ?? true,
        trackReposted: map['trackReposted'] ?? true,
        userFollowed: map['userFollowed'] ?? true,
        newRelease: map['newRelease'] ?? true,
        newMessage: map['newMessage'] ?? true,
        system: map['system'] ?? true,
        subscription: map['subscription'] ?? true,
      );
}
