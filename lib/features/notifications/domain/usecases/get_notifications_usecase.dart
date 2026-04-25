import '../entities/paginated_notifications.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repo;
  const GetNotificationsUseCase(this.repo);

  Future<PaginatedNotifications> call({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  }) =>
      repo.getNotifications(
        page: page,
        limit: limit,
        type: type,
        unreadOnly: unreadOnly,
      );
}
