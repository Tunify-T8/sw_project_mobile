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

  /// GET /notifications — returns { data: [...], meta: {...} }
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (type != null) params['type'] = type;
    if (unreadOnly != null) params['unread'] = unreadOnly;

    final res = await _dio.get(
      NotificationEndpoints.notifications,
      queryParameters: params,
    );
    return _toMap(res.data);
  }

  /// GET /notifications/unread-count — returns { unreadCount: N }
  Future<int> getUnreadCount() async {
    final res = await _dio.get(NotificationEndpoints.unreadCount);
    final body = _toMap(res.data);
    final data = body['data'];
    final payload = data is Map ? _toMap(data) : body;
    return _int(payload['unreadCount'] ?? payload['count']) ?? 0;
  }

  /// PATCH /notifications/:id — returns { message: '...' }
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    final res = await _dio.patch(NotificationEndpoints.single(notificationId));
    return _toMap(res.data);
  }

  /// PATCH /notifications/read-all — returns { message: '...', updatedCount: N }
  Future<Map<String, dynamic>> markAllAsRead() async {
    final res = await _dio.patch(NotificationEndpoints.readAll);
    return _toMap(res.data);
  }

  /// GET /notifications/preferences — returns { push: {...}, email: {...} }
  Future<NotificationPreferencesDto> getPreferences() async {
    final res = await _dio.get(NotificationEndpoints.preferences);
    return NotificationPreferencesDto.fromJson(_toMap(res.data));
  }

  /// PATCH /notifications/preferences — body { push?: {...}, email?: {...} }
  Future<void> updatePreferences({
    Map<String, bool>? push,
    Map<String, bool>? email,
  }) async {
    final data = <String, dynamic>{};
    if (push != null) data['push'] = push;
    if (email != null) data['email'] = email;
    await _dio.patch(NotificationEndpoints.preferences, data: data);
  }

  /// Coerces the raw Dio response into a [Map<String, dynamic>].
  /// Does NOT unwrap envelope wrappers — callers get the raw top-level object.
  static Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    throw StateError(
      'Unexpected notification API response type: ${raw.runtimeType}',
    );
  }

  static int? _int(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '');
  }
}
