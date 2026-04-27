import '../entities/message_entity.dart';
import '../entities/paginated_conversations.dart';
import '../entities/paginated_messages.dart';
import '../entities/realtime_event.dart';
import '../entities/send_message_draft.dart';

/// Abstraction over the messaging data layer.
/// UI/providers depend ONLY on this — never on the concrete impl.
abstract class MessagingRepository {
  Future<PaginatedConversations> getConversations({int page = 1, int limit = 20});
  Future<String> createOrGetConversation(String otherUserId);
  Future<void> deleteConversation(String conversationId);
  Future<PaginatedMessages> getMessages(String conversationId, {int page = 1, int limit = 20});

  /// Sends a message. In real mode this goes over the websocket and resolves
  /// once the backend acks (`message:sent`). In mock mode it resolves
  /// synchronously against the in-memory store.
  Future<MessageEntity> sendMessage(String conversationId, SendMessageDraft draft);

  Future<void> markConversationRead(String conversationId);
  Future<int> getUnreadCount();
  Future<void> archiveConversation(String conversationId);
  Future<void> unarchiveConversation(String conversationId);
  Future<void> blockConversation(String conversationId);

  /// Joins the websocket room for a conversation so that `message:received`
  /// events for it are delivered. Safe to call repeatedly.
  Future<void> joinConversation(String conversationId);
  Future<void> leaveConversation(String conversationId);

  /// Lazy stream of realtime events — repo implementations are responsible
  /// for the underlying WebSocket lifecycle.
  Stream<RealtimeMessagingEvent> realtimeEvents();
  Future<void> connectRealtime();
  Future<void> disconnectRealtime();
}
