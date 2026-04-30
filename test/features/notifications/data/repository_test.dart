import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features\notifications/data/api/notification_api.dart';
import 'package:software_project/features/notifications/data/repository/real_notification_repository_impl.dart';
import 'package:software_project/features/notifications/domain/entities/notification_type.dart';

void main() {
  group('RealNotificationRepositoryImpl', () {
    test('getNotifications calls API with parameters', () async {
      final api = _MockNotificationApi();
      final repo = RealNotificationRepositoryImpl(api);

      await repo.getNotifications(page: 2, limit: 30, type: 'like');

      expect(api.lastGetNotificationsPage, 2);
      expect(api.lastGetNotificationsLimit, 30);
      expect(api.lastGetNotificationsType, 'like');
    });

    test('getUnreadCount calls API', () async {
      final api = _MockNotificationApi();
      api.mockUnreadCount = 5;
      final repo = RealNotificationRepositoryImpl(api);

      final count = await repo.getUnreadCount();

      expect(count, 5);
      expect(api.getUnreadCountCalled, true);
    });

    test('getPreferences calls API', () async {
      final api = _MockNotificationApi();
      final repo = RealNotificationRepositoryImpl(api);

      await repo.getPreferences();

      expect(api.getPreferencesCalled, true);
    });

    test('markAsRead calls API with notification id', () async {
      final api = _MockNotificationApi();
      final repo = RealNotificationRepositoryImpl(api);

      await repo.markAsRead('notif-123');

      expect(api.lastMarkAsReadId, 'notif-123');
    });

    test('markAllAsRead calls API', () async {
      final api = _MockNotificationApi();
      final repo = RealNotificationRepositoryImpl(api);

      await repo.markAllAsRead();

      expect(api.markAllAsReadCalled, true);
    });

    test('updatePreferences calls API', () async {
      final api = _MockNotificationApi();
      final repo = RealNotificationRepositoryImpl(api);

      await repo.updatePreferences(
        const PreferenceChannelUpdate(
          trackLiked: false,
        ),
      );

      expect(api.updatePreferencesCalled, true);
    });
  });
}

// Mock API for testing
class _MockNotificationApi implements NotificationApi {
  int lastGetNotificationsPage = 0;
  int lastGetNotificationsLimit = 0;
  String? lastGetNotificationsType;
  bool? lastGetNotificationsUnreadOnly;
  bool getUnreadCountCalled = false;
  bool getPreferencesCalled = false;
  bool markAllAsReadCalled = false;
  String lastMarkAsReadId = '';
  bool updatePreferencesCalled = false;
  int mockUnreadCount = 0;

  @override
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  }) async {
    lastGetNotificationsPage = page;
    lastGetNotificationsLimit = limit;
    lastGetNotificationsType = type;
    lastGetNotificationsUnreadOnly = unreadOnly;
    return {'data': []};
  }

  @override
  Future<int> getUnreadCount() async {
    getUnreadCountCalled = true;
    return mockUnreadCount;
  }

  @override
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    lastMarkAsReadId = notificationId;
    return {};
  }

  @override
  Future<Map<String, dynamic>> markAllAsRead() async {
    markAllAsReadCalled = true;
    return {};
  }

  @override
  Future<dynamic> getPreferences() async {
    getPreferencesCalled = true;
    return {};
  }

  @override
  Future<void> updatePreferences({
    Map<String, bool>? push,
    Map<String, bool>? email,
  }) async {
    updatePreferencesCalled = true;
  }
}

class PreferenceChannelUpdate {
  final bool? trackLiked;

  const PreferenceChannelUpdate({this.trackLiked});
}
