import 'package:dio/dio.dart';

import '../dto/conversation_dto.dart';
import '../dto/message_dto.dart';
import '../dto/paginated_dto.dart';
import '../../domain/entities/send_message_draft.dart';

/// Thin HTTP wrapper for the Module 9 endpoints.
/// All endpoint paths are centralized here — when the backend contract changes
/// only this file and `MessagingEndpoints` need to be touched.
class MessagingEndpoints {
  MessagingEndpoints._();
  static const String conversations = '/me/conversations';
  static const String unreadCount = '/me/messages/unread-count';
  static String conversation(String id) => '/conversations/$id';
  static String messages(String id) => '/conversations/$id/messages';
  static String read(String id) => '/conversations/$id/read';
  static String block(String id) => '/conversations/$id/block';
}

class MessagingApi {
  final Dio _dio;
  MessagingApi(this._dio);

  Future<PaginatedDto<ConversationDto>> getConversations({int page = 1, int limit = 20}) async {
    final res = await _dio.get(MessagingEndpoints.conversations,
        queryParameters: {'page': page, 'limit': limit});
    return PaginatedDto<ConversationDto>.fromJson(
        _asMap(res.data), ConversationDto.fromJson);
  }

  Future<String> createOrGetConversation(String userId) async {
    final res = await _dio.post(MessagingEndpoints.conversations, data: {'userId': userId});
    return (_asMap(res.data)['conversationId'] ?? '').toString();
  }

  Future<void> deleteConversation(String id) =>
      _dio.delete(MessagingEndpoints.conversation(id));

  Future<PaginatedDto<MessageDto>> getMessages(String id, {int page = 1, int limit = 20}) async {
    final res = await _dio.get(MessagingEndpoints.messages(id),
        queryParameters: {'page': page, 'limit': limit});
    return PaginatedDto<MessageDto>.fromJson(
      _asMap(res.data),
      (m) => MessageDto.fromJson(m, fallbackConversationId: id),
    );
  }

  Future<MessageDto> sendMessage(String id, SendMessageDraft draft) async {
    final payload = <String, dynamic>{
      'type': draft.type.name.toUpperCase(),
      if (draft.text != null) 'text': draft.text,
      if (draft.attachments.isNotEmpty)
        'attachments': draft.attachments
            .map((a) => {'id': a.id, 'type': a.type.name.toUpperCase()})
            .toList(),
    };
    final res = await _dio.post(MessagingEndpoints.messages(id), data: payload);
    return MessageDto.fromJson(_asMap(res.data), fallbackConversationId: id);
  }

  Future<void> markRead(String id) => _dio.post(MessagingEndpoints.read(id));

  Future<int> getUnreadCount() async {
    final res = await _dio.get(MessagingEndpoints.unreadCount);
    return (_asMap(res.data)['unreadCount'] as int?) ?? 0;
  }

  Future<void> block(String id) => _dio.post(MessagingEndpoints.block(id));

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw StateError('Unexpected messaging API response: $raw');
    }
    if (raw['data'] is Map<String, dynamic>) return raw['data'] as Map<String, dynamic>;
    return raw;
  }
}
