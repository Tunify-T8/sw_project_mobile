import 'notification_entity.dart';

class PaginatedNotifications {
  final List<NotificationEntity> items;
  final int page;
  final int limit;
  final int total;
  final int unreadCount;

  const PaginatedNotifications({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.unreadCount,
  });
}
