import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/notifications/domain/entities/paginated_notifications.dart';
import 'package:software_project/features/notifications/domain/entities/notification_entity.dart';
import 'package:software_project/features/notifications/domain/entities/notification_preferences_entity.dart';
import 'package:software_project/features/notifications/domain/entities/notification_type.dart';
import 'package:software_project/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:software_project/features/notifications/domain/usecases/get_notification_preferences_usecase.dart';
import 'package:software_project/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:software_project/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:software_project/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:software_project/features/notifications/domain/repositories/notification_repository.dart';

void main() {
  group('GetNotificationsUseCase', () {
    test('calls repository with default parameters', () async {
      final repository = _MockNotificationRepository();
      final useCase = GetNotificationsUseCase(repository);

      await useCase();

      expect(repository.lastGetNotificationsPage, 1);
      expect(repository.lastGetNotificationsLimit, 20);
      expect(repository.lastGetNotificationsType, isNull);
      expect(repository.lastGetNotificationsUnreadOnly, isNull);
    });

    test('calls repository with pagination parameters', () async {
      final repository = _MockNotificationRepository();
      final useCase = GetNotificationsUseCase(repository);

      await useCase(page: 3, limit: 50);

      expect(repository.lastGetNotificationsPage, 3);
      expect(repository.lastGetNotificationsLimit, 50);
    });

    test('calls repository with type filter', () async {
      final repository = _MockNotificationRepository();
      final useCase = GetNotificationsUseCase(repository);

      await useCase(type: 'like');

      expect(repository.lastGetNotificationsType, 'like');
    });

    test('calls repository with unread filter', () async {
      final repository = _MockNotificationRepository();
      final useCase = GetNotificationsUseCase(repository);

      await useCase(unreadOnly: true);

      expect(repository.lastGetNotificationsUnreadOnly, true);
    });

    test('returns paginated notifications', () async {
      final repository = _MockNotificationRepository();
      final useCase = GetNotificationsUseCase(repository);

      final result = await useCase();

      expect(result, isA<PaginatedNotifications>());
    });
  });

  group('GetNotificationPreferencesUseCase', () {
    test('calls repository to get preferences', () async {
      final repository = _MockNotificationRepository();
      final useCase = GetNotificationPreferencesUseCase(repository);

      final prefs = await useCase();

      expect(prefs, isA<NotificationPreferencesEntity>());
      expect(repository.getPreferencesCalled, true);
    });
  });

  group('GetUnreadCountUseCase', () {
    test('calls repository to get unread count', () async {
      final repository = _MockNotificationRepository();
      repository.unreadCount = 5;
      final useCase = GetUnreadCountUseCase(repository);

      final count = await useCase();

      expect(count, 5);
      expect(repository.getUnreadCountCalled, true);
    });

    test('returns zero when no unread notifications', () async {
      final repository = _MockNotificationRepository();
      repository.unreadCount = 0;
      final useCase = GetUnreadCountUseCase(repository);

      final count = await useCase();

      expect(count, 0);
    });
  });

  group('MarkNotificationReadUseCase', () {
    test('calls repository to mark single notification as read', () async {
      final repository = _MockNotificationRepository();
      final useCase = MarkNotificationReadUseCase(repository);

      await useCase('notif-123');

      expect(repository.lastMarkReadNotificationId, 'notif-123');
      expect(repository.markReadCalled, true);
    });
  });

  group('MarkAllNotificationsReadUseCase', () {
    test('calls repository to mark all as read', () async {
      final repository = _MockNotificationRepository();
      final useCase = MarkAllNotificationsReadUseCase(repository);

      await useCase();

      expect(repository.markAllReadCalled, true);
    });
  });
}

// Mock repository for testing use cases
class _MockNotificationRepository implements NotificationRepository {
  int lastGetNotificationsPage = 0;
  int lastGetNotificationsLimit = 0;
  String? lastGetNotificationsType;
  bool? lastGetNotificationsUnreadOnly;
  bool getPreferencesCalled = false;
  bool getUnreadCountCalled = false;
  int unreadCount = 0;
  bool markReadCalled = false;
  String lastMarkReadNotificationId = '';
  bool markAllReadCalled = false;

  @override
  Future<PaginatedNotifications> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  }) async {
    lastGetNotificationsPage = page;
    lastGetNotificationsLimit = limit;
    lastGetNotificationsType = type;
    lastGetNotificationsUnreadOnly = unreadOnly;

    return PaginatedNotifications(
      data: [
        NotificationEntity(
          id: 'notif-1',
          type: NotificationType.like,
          message: 'Someone liked your track',
          createdAt: DateTime.now(),
        ),
      ],
      total: 1,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    getUnreadCountCalled = true;
    return unreadCount;
  }

  @override
  Future<NotificationPreferencesEntity> getPreferences() async {
    getPreferencesCalled = true;
    return const NotificationPreferencesEntity();
  }

  @override
  Future<void> updatePreferences(NotificationPreferencesEntity preferences) async {}

  @override
  Future<void> markAsRead(String notificationId) async {
    markReadCalled = true;
    lastMarkReadNotificationId = notificationId;
  }

  @override
  Future<void> markAllAsRead() async {
    markAllReadCalled = true;
  }
}
