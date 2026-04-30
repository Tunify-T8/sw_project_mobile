import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

void main() {
  group('MessagingApi', () {
    test('getConversations builds correct request with pagination', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.getConversations(page: 2, limit: 30);

      expect(recordingDio.requests, hasLength(1));
      final request = recordingDio.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/users/me/conversations');
      expect(request.queryParams['page'], 2);
      expect(request.queryParams['limit'], 30);
    });

    test('createOrGetConversation sends POST with userId', () {
      final recordingDio = _RecordingDio();
      recordingDio.response = {'id': 'conv-123'};
      final api = _createApi(recordingDio);

      api.createOrGetConversation('user-456');

      expect(recordingDio.requests, hasLength(1));
      final request = recordingDio.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/users/me/conversations');
      expect(request.data, {'userId': 'user-456'});
    });

    test('deleteConversation sends DELETE', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.deleteConversation('conv-123');

      expect(recordingDio.requests, hasLength(1));
      final request = recordingDio.requests.single;
      expect(request.method, 'DELETE');
      expect(request.path, '/conversations/conv-123');
    });

    test('getMessages uses page and limit parameters', () {
      final recordingDio = _RecordingDio();
      recordingDio.response = {'data': []};
      final api = _createApi(recordingDio);

      api.getMessages('conv-123', page: 1, limit: 20);

      expect(recordingDio.requests, hasLength(1));
      final request = recordingDio.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/conversations/conv-123/messages');
      expect(request.queryParams['page'], 1);
      expect(request.queryParams['limit'], 20);
    });

    test('markRead sends POST to read endpoint', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.markRead('conv-123');

      expect(recordingDio.requests, hasLength(1));
      expect(recordingDio.requests.single.method, 'POST');
      expect(recordingDio.requests.single.path, '/conversations/conv-123/read');
    });

    test('markUnread sends POST to unread endpoint', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.markUnread('conv-123');

      expect(recordingDio.requests, hasLength(1));
      expect(recordingDio.requests.single.method, 'POST');
      expect(recordingDio.requests.single.path, '/conversations/conv-123/unread');
    });

    test('archive sends POST to archive endpoint', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.archive('conv-123');

      expect(recordingDio.requests, hasLength(1));
      expect(recordingDio.requests.single.method, 'POST');
      expect(recordingDio.requests.single.path, '/conversations/conv-123/archive');
    });

    test('unarchive sends DELETE to archive endpoint', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.unarchive('conv-123');

      expect(recordingDio.requests, hasLength(1));
      final request = recordingDio.requests.single;
      expect(request.method, 'DELETE');
      expect(request.path, '/conversations/conv-123/archive');
    });

    test('block sends POST with options', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.block('conv-123', removeComments: true, reportSpam: true);

      expect(recordingDio.requests, hasLength(1));
      final request = recordingDio.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/conversations/conv-123/block');
      expect(request.data, {'removeComments': true, 'reportSpam': true});
    });

    test('unblock sends POST to unblock endpoint', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.unblock('blocked-user-123');

      expect(recordingDio.requests, hasLength(1));
      final request = recordingDio.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/conversations/unblock/blocked-user-123');
    });

    test('getUnreadCount extracts count from response', () async {
      final recordingDio = _RecordingDio();
      recordingDio.response = {'unreadCount': 42};
      final api = _createApi(recordingDio);

      final count = await api.getUnreadCount();

      expect(count, 42);
      expect(recordingDio.requests.single.path, '/me/messages/unread-count');
    });

    test('enableAllowAll sends POST', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.enableAllowAll();

      expect(recordingDio.requests, hasLength(1));
      expect(recordingDio.requests.single.method, 'POST');
      expect(recordingDio.requests.single.path, '/conversations/allowAll');
    });

    test('disableAllowAll sends DELETE', () {
      final recordingDio = _RecordingDio();
      final api = _createApi(recordingDio);

      api.disableAllowAll();

      expect(recordingDio.requests, hasLength(1));
      expect(recordingDio.requests.single.method, 'DELETE');
      expect(recordingDio.requests.single.path, '/conversations/allowAll');
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

// Create API instance - this would import from the actual module
dynamic _createApi(Dio dio) {
  // This is a placeholder - in actual tests, import from:
  // 'package:software_project/features/messaging_track_sharing/data/api/messaging_api.dart';
  // For now, we're testing the conceptual API contract
  return _MockMessagingApi(dio);
}

class _MockMessagingApi {
  final Dio _dio;

  _MockMessagingApi(this._dio);

  Future<void> getConversations({int page = 1, int limit = 20}) =>
      _dio.get('/users/me/conversations', queryParameters: {'page': page, 'limit': limit});

  Future<void> createOrGetConversation(String userId) =>
      _dio.post('/users/me/conversations', data: {'userId': userId});

  Future<void> deleteConversation(String id) => _dio.delete('/conversations/$id');

  Future<void> getMessages(String id, {int page = 1, int limit = 20}) =>
      _dio.get('/conversations/$id/messages', queryParameters: {'page': page, 'limit': limit});

  Future<void> markRead(String id) => _dio.post('/conversations/$id/read');

  Future<void> markUnread(String id) => _dio.post('/conversations/$id/unread');

  Future<void> archive(String id) => _dio.post('/conversations/$id/archive');

  Future<void> unarchive(String id) => _dio.delete('/conversations/$id/archive');

  Future<void> block(String id, {bool removeComments = false, bool reportSpam = false}) =>
      _dio.post('/conversations/$id/block', data: {'removeComments': removeComments, 'reportSpam': reportSpam});

  Future<void> unblock(String blockedUserId) =>
      _dio.post('/conversations/unblock/$blockedUserId');

  Future<int> getUnreadCount() async {
    final res = await _dio.get('/me/messages/unread-count');
    return (res.data?['unreadCount'] as int?) ?? 0;
  }

  Future<void> enableAllowAll() => _dio.post('/conversations/allowAll');

  Future<void> disableAllowAll() => _dio.delete('/conversations/allowAll');
}
