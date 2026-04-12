import '../../domain/entities/message_attachment.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/paginated_conversations.dart';
import '../../domain/entities/paginated_messages.dart';
import '../../domain/entities/realtime_event.dart';
import '../../domain/entities/send_message_draft.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../dto/message_dto.dart';
import '../mappers/messaging_mapper.dart';
import '../services/mock_messaging_socket.dart';
import '../services/mock_messaging_store.dart';
import '../dto/conversation_dto.dart';

/// Mock repo — all state lives in [MockMessagingStore].
/// Mirrors [RealMessagingRepository] so providers can swap transparently.
class MockMessagingRepository implements MessagingRepository {
  final MockMessagingStore _store;
  final MockMessagingSocket _socket;
  MockMessagingRepository(this._store, this._socket);

  @override
  Future<PaginatedConversations> getConversations({int page = 1, int limit = 20}) async {
    final all = _store.conversations.values.map(MessagingMapper.conversation).toList()
      ..sort((a, b) => (b.lastMessageAt ?? DateTime(0))
          .compareTo(a.lastMessageAt ?? DateTime(0)));
    return PaginatedConversations(
        items: all, page: page, limit: limit, total: all.length);
  }

  @override
  Future<String> createOrGetConversation(String otherUserId) async {
    final id = _store.currentUserId.compareTo(otherUserId) < 0
        ? '${_store.currentUserId}:$otherUserId'
        : '$otherUserId:${_store.currentUserId}';
    _store.messages.putIfAbsent(id, () => []);
    return id;
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    _store.conversations.remove(conversationId);
    _store.messages.remove(conversationId);
  }

  @override
  Future<PaginatedMessages> getMessages(String conversationId,
      {int page = 1, int limit = 20}) async {
    final list = (_store.messages[conversationId] ?? const <MessageDto>[])
        .map(MessagingMapper.message)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return PaginatedMessages(
        items: list, page: page, limit: limit, total: list.length);
  }

  @override
  Future<MessageEntity> sendMessage(String conversationId, SendMessageDraft draft) async {
    final dto = MessageDto(
      id: 'm${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: _store.currentUserId,
      type: draft.type == MessageType.attachment ? 'ATTACHMENT' : 'TEXT',
      text: draft.text,
      createdAt: DateTime.now(),
      isRead: false,
    );
    _store.messages.putIfAbsent(conversationId, () => []).add(dto);
    final entity = MessagingMapper.message(dto);
    _socket.emit(MessageReceivedEvent(entity));
    return entity;
  }

    @override
  Future<void> markConversationRead(String conversationId) async {
    final c = _store.conversations[conversationId];
    if (c == null) return;
    _store.conversations[conversationId] = ConversationDto(
      conversationId: c.conversationId,
      otherUser: c.otherUser,
      lastMessagePreview: c.lastMessagePreview,
      lastMessageAt: c.lastMessageAt,
      unreadCount: 0,
      isBlocked: c.isBlocked,
    );
    _socket.emit(MessageReadEvent(
      conversationId: conversationId,
      readerUserId: _store.currentUserId,
    ));
  }

  @override
  Future<int> getUnreadCount() async => _store.conversations.values
      .fold<int>(0, (sum, c) => sum + c.unreadCount);

  @override
  Future<void> blockConversation(String conversationId) async =>
      _socket.emit(ConversationBlockedEvent(conversationId));

  @override
  Stream<RealtimeMessagingEvent> realtimeEvents() => _socket.events;

  @override
  Future<void> connectRealtime() => _socket.connect();

  @override
  Future<void> disconnectRealtime() => _socket.disconnect();
}
