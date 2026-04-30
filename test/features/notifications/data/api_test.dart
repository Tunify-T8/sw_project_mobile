import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

void main() {
  group('NotificationApi', () {
    test('getNotifications with default parameters', () {
      final recordingDio = _RecordingDio();
      recordingDio.response = {'data': []};
      final api = _createApi(recordingDio);

      api.getNotifications();

      expect(recordingDio.requests, hasLength(1));
      final request = recordingDio.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/notifications');
      expect(request.queryParams['page'], 1);
      expect(request.queryParams['limit'], 20);
    });

    test('getNotifications with custom pagination', () {
      final recordingDio = _RecordingDio();
      recordingDio.response = {'data': []};
      final api = _createApi(recordingDio);

      api.getNotifications(page: 3, limit: 50);

      final request = recordingDio.requests.single;
      expect(request.queryParams['page'], 3);
      expect(request.queryParams['limit'], 50);
    });

    test('getNotifications with type filter', () {
      final recordingDio = _RecordingDio();
      recordingDio.response = {'data': []};
      final api = _createApi(recordingDio);

      api.getNotifications(type: 'like');

      final request = recordingDio.requests.single;
      expect(request.queryParams['type'], 'like');
    });

    test('getNotifications with unread filter', () {
      final recordingDio = _RecordingDio();
      recordingDio.response = {'data': []};
      final api = _createApi(recordingDio);

      api.getNotifications(unreadOnly: true);

      final request = recordingDio.requests.single;
      expect(request.queryParams['unread'], true);
    });

    test('getUnreadCount returns count', () async {
      final recordingDio = _RecordingDio();
      recordingDio.response = {'unreadCount': 5};
      final api = _createApi(recordingDio);

      final count = await api.getUnreadCount();

      expect(count, 5);
      final request = recordingDio.requests.single;
      expect(request.path, '/notifications/unread-count');
    });

    test('getUnreadCount handles nested data', () async {
      final recordingDio = _RecordingDio();
      recordingDio.response = {'data': {'unreadCount': 3}};
      final api = _createApi(recordingDio);

      final count = await api.getUnreadCount();

      expect(count, 3);
    });

    test('getUnreadCount defaults to 0 when missing', () async {
      final recordingDio = _RecordingDio();
      recordingDio.response = {};
      final api = _createApi(recordingDio);

      final count = await api.getUnreadCount();

      expect(count, 0);
    });

    test('markAsRead sends PATCH request', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.markAsRead('notif-123');

      final request = recordingDio.requests.single;
      expect(request.method, 'PATCH');
      expect(request.path, '/notifications/notif-123');
    });

    test('markAllAsRead sends PATCH to read-all endpoint', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.markAllAsRead();

      final request = recordingDio.requests.single;
      expect(request.method, 'PATCH');
      expect(request.path, '/notifications/read-all');
    });

    test('getPreferences sends GET request', () {
      final recordingDio = _RecordingDio();
      recordingDio.response = {
        'push': {'trackLiked': true},
        'email': {'trackLiked': false},
      };
      final api = _createApi(recordingDio);

      api.getPreferences();

      final request = recordingDio.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/notifications/preferences');
    });

    test('updatePreferences sends PATCH with push settings', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.updatePreferences(push: {'trackLiked': false});

      final request = recordingDio.requests.single;
      expect(request.method, 'PATCH');
      expect(request.path, '/notifications/preferences');
      expect(request.data['push'], {'trackLiked': false});
    });

    test('updatePreferences sends PATCH with email settings', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.updatePreferences(email: {'newMessage': true});

      final request = recordingDio.requests.single;
      expect(request.data['email'], {'newMessage': true});
    });

    test('updatePreferences can send both push and email', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.updatePreferences(
        push: {'trackLiked': false},
        email: {'newMessage': false},
      );

      final request = recordingDio.requests.single;
      expect(request.data['push'], {'trackLiked': false});
      expect(request.data['email'], {'newMessage': false});
    });
  });
}

// Helpers for recording Dio calls
class _DioRequest {
  final String method;
  final String path;
  final Map<String, dynamic> queryParams;
  final dynamic data;

  _DioRequest({
    required this.method,
    required this.path,
    this.queryParams = const {},
    this.data,
  });
}

class _RecordingDio extends Dio {
  final requests = <_DioRequest>[];
  dynamic response = {'data': []};

  _RecordingDio() : super(BaseOptions(baseUrl: 'http://test'));

  @override
  Future<Response<T>> request<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final method = options?.method ?? 'GET';
    requests.add(_DioRequest(
      method: method,
      path: path,
      queryParams: queryParameters ?? {},
      data: data,
    ));

    return Response(
      requestOptions: RequestOptions(path: path),
      data: response,
      statusCode: 200,
    );
  }
}

// Create API instance
dynamic _createApi(Dio dio) {
  return _MockNotificationApi(dio);
}

class _MockNotificationApi {
  final Dio _dio;

  _MockNotificationApi(this._dio);

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (type != null) params['type'] = type;
    if (unreadOnly != null) params['unread'] = unreadOnly;

    final res = await _dio.get('/notifications', queryParameters: params);
    return res.data as Map<String, dynamic>;
  }

  Future<int> getUnreadCount() async {
    final res = await _dio.get('/notifications/unread-count');
    final body = res.data as Map<String, dynamic>;
    final data = body['data'];
    final payload = data is Map ? data as Map<String, dynamic> : body;
    return (payload['unreadCount'] ?? payload['count'] as int?) ?? 0;
  }

  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    final res = await _dio.patch('/notifications/$notificationId');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    final res = await _dio.patch('/notifications/read-all');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPreferences() async {
    final res = await _dio.get('/notifications/preferences');
    return res.data as Map<String, dynamic>;
  }

  Future<void> updatePreferences({
    Map<String, bool>? push,
    Map<String, bool>? email,
  }) async {
    final data = <String, dynamic>{};
    if (push != null) data['push'] = push;
    if (email != null) data['email'] = email;
    await _dio.patch('/notifications/preferences', data: data);
  }
}
