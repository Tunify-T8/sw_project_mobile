import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/entities/paginated_notifications.dart';
import '../../domain/repositories/notification_repository.dart';
import '../api/notification_api.dart';
import '../mappers/notification_mapper.dart';
import '../services/notification_socket.dart';

class RealNotificationRepository implements NotificationRepository {
  final NotificationApi _api;
  final NotificationSocket _socket;

  RealNotificationRepository(this._api, this._socket);

  @override
  Future<PaginatedNotifications> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  }) async {
    final json = await _api.getNotifications(
      page: page,
      limit: limit,
      type: type,
      unreadOnly: unreadOnly,
    );
    return NotificationMapper.paginatedFromJson(json);
  }

  @override
  Future<int> getUnreadCount() => _api.getUnreadCount();

  @override
  Future<void> markAsRead(String notificationId) =>
      _api.markAsRead(notificationId);

  @override
  Future<int> markAllAsRead() async {
    final result = await _api.markAllAsRead();
    return (result['updatedCount'] as int?) ?? 0;
  }

  @override
  Future<NotificationPreferencesEntity> getPreferences() async {
    final dto = await _api.getPreferences();
    return NotificationMapper.preferences(dto);
  }

  @override
  Future<void> updatePreferences({
    Map<String, bool>? push,
    Map<String, bool>? email,
  }) =>
      _api.updatePreferences(push: push, email: email);

  // ── Realtime ──────────────────────────────────────────────────────────────

  @override
  Stream<NotificationEntity> realtimeNotifications() => _socket.notifications;

  @override
  Future<void> connectRealtime() => _socket.connect();

  @override
  Future<void> disconnectRealtime() => _socket.disconnect();
}
