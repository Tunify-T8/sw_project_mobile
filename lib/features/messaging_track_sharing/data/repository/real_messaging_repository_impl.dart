import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/paginated_conversations.dart';
import '../../domain/entities/paginated_messages.dart';
import '../../domain/entities/realtime_event.dart';
import '../../domain/entities/send_message_draft.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../api/messaging_api.dart';
import '../mappers/messaging_mapper.dart';
import '../services/messaging_socket.dart';

/// Real backend-backed implementation. REST via [MessagingApi],
/// realtime via [MessagingSocket].
class RealMessagingRepository implements MessagingRepository {
  final MessagingApi _api;
  final MessagingSocket _socket;
  RealMessagingRepository(this._api, this._socket);

  @override
  Future<PaginatedConversations> getConversations({int page = 1, int limit = 20}) async =>
      MessagingMapper.conversations(await _api.getConversations(page: page, limit: limit));

  @override
  Future<String> createOrGetConversation(String otherUserId) =>
      _api.createOrGetConversation(otherUserId);

  @override
  Future<void> deleteConversation(String conversationId) =>
      _api.deleteConversation(conversationId);

  @override
  Future<PaginatedMessages> getMessages(String conversationId,
          {int page = 1, int limit = 20}) async =>
      MessagingMapper.messages(
          await _api.getMessages(conversationId, page: page, limit: limit));

  @override
  Future<MessageEntity> sendMessage(String conversationId, SendMessageDraft draft) async =>
      MessagingMapper.message(await _api.sendMessage(conversationId, draft));

  @override
  Future<void> markConversationRead(String conversationId) =>
      _api.markRead(conversationId);

  @override
  Future<int> getUnreadCount() => _api.getUnreadCount();

  @override
  Future<void> blockConversation(String conversationId) => _api.block(conversationId);

  @override
  Stream<RealtimeMessagingEvent> realtimeEvents() => _socket.events;

  @override
  Future<void> connectRealtime() => _socket.connect();

  @override
  Future<void> disconnectRealtime() => _socket.disconnect();
}
