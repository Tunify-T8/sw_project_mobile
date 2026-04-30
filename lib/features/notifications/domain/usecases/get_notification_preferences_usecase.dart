import '../entities/notification_preferences_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationPreferencesUseCase {
  final NotificationRepository repo;
  const GetNotificationPreferencesUseCase(this.repo);

  Future<NotificationPreferencesEntity> call() => repo.getPreferences();
}
