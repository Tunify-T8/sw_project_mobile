import '../entities/notification_entity.dart';
import '../entities/notification_preferences_entity.dart';
import '../entities/paginated_notifications.dart';

/// Abstraction over the notifications data layer.
/// UI/providers depend ONLY on this — never on the concrete impl.
abstract class NotificationRepository {
  Future<PaginatedNotifications> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(String notificationId);

  Future<int> markAllAsRead();

  Future<NotificationPreferencesEntity> getPreferences();

  Future<void> updatePreferences({
    Map<String, bool>? push,
    Map<String, bool>? email,
  });

  // ── Realtime ──────────────────────────────────────────────────────────────

  /// Stream of notifications pushed by the server in real time.
  Stream<NotificationEntity> realtimeNotifications();

  /// Open the realtime connection. Must be called once (idempotent).
  Future<void> connectRealtime();

  /// Close the realtime connection.
  Future<void> disconnectRealtime();
}
