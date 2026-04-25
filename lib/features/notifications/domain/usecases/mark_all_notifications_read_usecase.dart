import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepository repo;
  const MarkAllNotificationsReadUseCase(this.repo);

  Future<int> call() => repo.markAllAsRead();
}
