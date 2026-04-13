import '../repositories/notification_repository.dart';

class UpdateNotificationPreferencesUseCase {
  final NotificationRepository repo;
  const UpdateNotificationPreferencesUseCase(this.repo);

  Future<void> call({
    Map<String, bool>? push,
    Map<String, bool>? email,
  }) =>
      repo.updatePreferences(push: push, email: email);
}
