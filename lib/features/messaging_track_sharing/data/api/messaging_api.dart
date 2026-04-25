import 'package:dio/dio.dart';

import '../dto/conversation_dto.dart';
import '../dto/message_dto.dart';
import '../dto/paginated_dto.dart';

/// REST endpoints for the messaging module.
///
/// Message *sending* is no longer exposed here — the backend moved it onto the
/// websocket (`message:send`). This file covers the REST surface only.
class MessagingEndpoints {
  MessagingEndpoints._();

  static const String conversations = '/users/me/conversations';
  static const String unreadCount = '/me/messages/unread-count';

  static String conversation(String id) => '/conversations/$id';
  static String messages(String id) => '/conversations/$id/messages';
  static String read(String id) => '/conversations/$id/read';
  static String unread(String id) => '/conversations/$id/unread';
  static String archive(String id) => '/conversations/$id/archive';
  static String block(String id) => '/conversations/$id/block';
  static String unblock(String blockedUserId) =>
      '/conversations/unblock/$blockedUserId';
}

class MessagingApi {
  final Dio _dio;
  MessagingApi(this._dio);

  Future<PaginatedDto<ConversationDto>> getConversations({
    int page = 1,
    int limit = 20,
    String? currentUserId,
  }) async {
    final res = await _dio.get(
      MessagingEndpoints.conversations,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedDto<ConversationDto>.fromJson(
      _asPaginatedMap(res.data),
      (m) => ConversationDto.fromJson(m, currentUserId: currentUserId),
    );
  }

  /// Creates or returns the existing conversation with [userId].
  /// Backend response: `{ id, user1Id, user2Id, status, createdAt, updatedAt }`.
  Future<String> createOrGetConversation(String userId) async {
    final res = await _dio.post(
      MessagingEndpoints.conversations,
      data: {'userId': userId},
    );
    final body = _asMap(res.data);
    final nested = _asNullableMap(body['conversation']);
    return (body['id'] ??
            body['_id'] ??
            body['conversationId'] ??
            body['conversation_id'] ??
            nested?['id'] ??
            nested?['_id'] ??
            nested?['conversationId'] ??
            '')
        .toString();
  }

  Future<void> deleteConversation(String id) =>
      _dio.delete(MessagingEndpoints.conversation(id));

  Future<PaginatedDto<MessageDto>> getMessages(
    String id, {
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get(
      MessagingEndpoints.messages(id),
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedDto<MessageDto>.fromJson(
      _asPaginatedMap(res.data),
      (m) => MessageDto.fromJson(m, fallbackConversationId: id),
    );
  }

  Future<void> markRead(String id) => _dio.post(MessagingEndpoints.read(id));

  Future<void> markUnread(String id) =>
      _dio.post(MessagingEndpoints.unread(id));

  Future<void> archive(String id) => _dio.post(MessagingEndpoints.archive(id));

  Future<int> getUnreadCount() async {
    final res = await _dio.get(MessagingEndpoints.unreadCount);
    return (_asMap(res.data)['unreadCount'] as int?) ?? 0;
  }

  Future<void> block(
    String id, {
    bool removeComments = false,
    bool reportSpam = false,
  }) => _dio.post(
    MessagingEndpoints.block(id),
    data: {'removeComments': removeComments, 'reportSpam': reportSpam},
  );

  Future<void> unblock(String blockedUserId) =>
      _dio.post(MessagingEndpoints.unblock(blockedUserId));

  /// Backend responses often come wrapped in `{ data: {...} }`. Unwrap when
  /// present and fail loudly for anything non-object.
  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw StateError('Unexpected messaging API response: $raw');
    }
    if (raw['data'] is Map<String, dynamic>) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw;
  }

  Map<String, dynamic> _asPaginatedMap(dynamic raw) {
    if (raw is List) return {'data': raw};
    final map = _asMap(raw);
    if (map['data'] is List) return map;
    final nested = _asNullableMap(map['data']);
    if (nested != null) return nested;
    return map;
  }

  Map<String, dynamic>? _asNullableMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
