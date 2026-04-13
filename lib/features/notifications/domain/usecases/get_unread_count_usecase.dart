import '../repositories/notification_repository.dart';

class GetUnreadCountUseCase {
  final NotificationRepository repo;
  const GetUnreadCountUseCase(this.repo);

  Future<int> call() => repo.getUnreadCount();
}
