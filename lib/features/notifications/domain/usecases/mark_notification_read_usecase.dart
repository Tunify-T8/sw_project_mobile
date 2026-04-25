import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repo;
  const MarkNotificationReadUseCase(this.repo);

  Future<void> call(String notificationId) => repo.markAsRead(notificationId);
}
