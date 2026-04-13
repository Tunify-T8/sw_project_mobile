import '../entities/notification_preferences_entity.dart';
import '../entities/paginated_notifications.dart';

/// Abstraction over the notifications data layer.
/// UI/providers depend ONLY on this — never on the concrete impl.
abstract class NotificationRepository {
  /// Fetch paginated notifications. Optionally filter by [type] (comma-separated)
  /// and [unreadOnly].
  Future<PaginatedNotifications> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  });

  /// Lightweight badge counter — returns only the unread count.
  Future<int> getUnreadCount();

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read. Returns the number of updated records.
  Future<int> markAllAsRead();

  /// Fetch the user's notification preferences for push and email channels.
  Future<NotificationPreferencesEntity> getPreferences();

  /// Partially update notification preferences.
  Future<void> updatePreferences({
    Map<String, bool>? push,
    Map<String, bool>? email,
  });
}
