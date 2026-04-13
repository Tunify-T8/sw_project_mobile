import 'package:dio/dio.dart';

import '../dto/notification_dto.dart';

class NotificationEndpoints {
  NotificationEndpoints._();
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
  static const String readAll = '/notifications/read-all';
  static const String preferences = '/notifications/preferences';
  static String single(String id) => '/notifications/$id';
}

class NotificationApi {
  final Dio _dio;
  NotificationApi(this._dio);

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (type != null) params['type'] = type;
    if (unreadOnly != null) params['unread'] = unreadOnly;

    final res = await _dio.get(
      NotificationEndpoints.notifications,
      queryParameters: params,
    );
    return _asMap(res.data);
  }

  Future<int> getUnreadCount() async {
    final res = await _dio.get(NotificationEndpoints.unreadCount);
    return (_asMap(res.data)['unreadCount'] as int?) ?? 0;
  }

  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    final res = await _dio.patch(
      NotificationEndpoints.single(notificationId),
    );
    return _asMap(res.data);
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    final res = await _dio.patch(NotificationEndpoints.readAll);
    return _asMap(res.data);
  }

  Future<NotificationPreferencesDto> getPreferences() async {
    final res = await _dio.get(NotificationEndpoints.preferences);
    return NotificationPreferencesDto.fromJson(_asMap(res.data));
  }

  Future<void> updatePreferences({
    Map<String, bool>? push,
    Map<String, bool>? email,
  }) async {
    final data = <String, dynamic>{};
    if (push != null) data['push'] = push;
    if (email != null) data['email'] = email;
    await _dio.patch(NotificationEndpoints.preferences, data: data);
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw StateError('Unexpected notification API response: $raw');
    }
    if (raw['data'] is Map<String, dynamic>) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw;
  }
}
