import 'dart:async';
import 'dart:math';

import '../../domain/entities/message_attachment.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/paginated_conversations.dart';
import '../../domain/entities/paginated_messages.dart';
import '../../domain/entities/realtime_event.dart';
import '../../domain/entities/send_message_draft.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../dto/conversation_dto.dart';
import '../dto/message_attachment_dto.dart';
import '../dto/message_dto.dart';
import '../dto/user_preview_dto.dart';
import '../mappers/messaging_mapper.dart';
import '../services/mock_messaging_socket.dart';
import '../services/mock_messaging_store.dart';

/// Mock repo — all state lives in [MockMessagingStore].
/// Mirrors [RealMessagingRepository] so providers can swap transparently.
class MockMessagingRepository implements MessagingRepository {
  final MockMessagingStore _store;
  final MockMessagingSocket _socket;
  final Random _rng = Random();

  MockMessagingRepository(this._store, this._socket);

  @override
  Future<PaginatedConversations> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final all = _store.conversations.values
        .where(
          (conversation) =>
              !_store.archivedConversationIds.contains(
                conversation.conversationId,
              ) &&
              !conversation.isBlocked,
        )
        .map(MessagingMapper.conversation)
        .toList()
      ..sort(
        (a, b) => (b.lastMessageAt ?? DateTime(0)).compareTo(
          a.lastMessageAt ?? DateTime(0),
        ),
      );

    return PaginatedConversations(
      items: all,
      page: page,
      limit: limit,
      total: all.length,
    );
  }

  @override
  Future<String> createOrGetConversation(String otherUserId) async {
    final id = _store.currentUserId.compareTo(otherUserId) < 0
        ? '${_store.currentUserId}:$otherUserId'
        : '$otherUserId:${_store.currentUserId}';

    _store.messages.putIfAbsent(id, () => []);

    _store.conversations.putIfAbsent(
      id,
      () => ConversationDto(
        conversationId: id,
        otherUser: UserPreviewDto(
          id: otherUserId,
          displayName: _displayNameFromUserId(otherUserId),
          avatarUrl: null,
        ),
        lastMessagePreview: null,
        lastMessageAt: null,
        unreadCount: 0,
      ),
    );

    return id;
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    // Archive behavior for mock mode:
    // the chat disappears from Activity, but its messages stay intact.
    if (_store.conversations.containsKey(conversationId)) {
      _store.archivedConversationIds.add(conversationId);
    }
  }

  @override
  Future<PaginatedMessages> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
    final list = (_store.messages[conversationId] ?? const <MessageDto>[])
        .map(MessagingMapper.message)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return PaginatedMessages(
      items: list,
      page: page,
      limit: limit,
      total: list.length,
    );
  }

  @override
  Future<MessageEntity> sendMessage(
    String conversationId,
    SendMessageDraft draft,
  ) async {
    final existingConversation = _store.conversations[conversationId];
    if (existingConversation != null && existingConversation.isBlocked) {
      throw Exception('This conversation is blocked.');
    }

    final attachmentDtos = draft.attachments
        .map(
          (attachment) => MessageAttachmentDto(
            id: attachment.id,
            type: attachment.type == MessageAttachmentType.collection
                ? 'COLLECTION'
                : 'TRACK',
            title: attachment.title,
            artworkUrl: attachment.artworkUrl,
          ),
        )
        .toList();

    final dto = MessageDto(
      id: 'm${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: _store.currentUserId,
      type: draft.type == MessageType.attachment ? 'ATTACHMENT' : 'TEXT',
      text: draft.text,
      attachments: attachmentDtos,
      createdAt: DateTime.now(),
      isRead: true,
    );

    _store.messages.putIfAbsent(conversationId, () => []).add(dto);
    _store.archivedConversationIds.remove(conversationId);
    _bumpConversationPreview(
      conversationId: conversationId,
      preview: _previewFor(dto),
      at: dto.createdAt,
      unreadDelta: 0,
      resetUnread: true,
    );

    final entity = MessagingMapper.message(dto);
    _socket.emit(MessageReceivedEvent(entity));
    _scheduleAutoReply(conversationId);
    return entity;
  }

  @override
  Future<void> markConversationRead(String conversationId) async {
    final conversation = _store.conversations[conversationId];
    if (conversation == null) return;

    _store.conversations[conversationId] = ConversationDto(
      conversationId: conversation.conversationId,
      otherUser: conversation.otherUser,
      lastMessagePreview: conversation.lastMessagePreview,
      lastMessageAt: conversation.lastMessageAt,
      unreadCount: 0,
      isBlocked: conversation.isBlocked,
    );

    _socket.emit(
      MessageReadEvent(
        conversationId: conversationId,
        readerUserId: _store.currentUserId,
      ),
    );
  }

  @override
  Future<int> getUnreadCount() async => _store.conversations.values
      .where(
        (conversation) =>
            !_store.archivedConversationIds.contains(
              conversation.conversationId,
            ) &&
            !conversation.isBlocked,
      )
      .fold<int>(0, (sum, conversation) => sum + conversation.unreadCount);

  @override
  Future<void> archiveConversation(String conversationId) async {
    if (_store.conversations.containsKey(conversationId)) {
      _store.archivedConversationIds.add(conversationId);
    }
  }

  @override
  Future<void> unarchiveConversation(String conversationId) async {
    _store.archivedConversationIds.remove(conversationId);
  }

  @override
  Future<void> blockConversation(String conversationId) async {
    final conversation = _store.conversations[conversationId];
    if (conversation != null) {
      _store.conversations[conversationId] = ConversationDto(
        conversationId: conversation.conversationId,
        otherUser: conversation.otherUser,
        lastMessagePreview: conversation.lastMessagePreview,
        lastMessageAt: conversation.lastMessageAt,
        unreadCount: conversation.unreadCount,
        isBlocked: true,
      );
      _store.archivedConversationIds.remove(conversationId);
    }

    _socket.emit(ConversationBlockedEvent(conversationId));
  }

  @override
  Stream<RealtimeMessagingEvent> realtimeEvents() => _socket.events;

  @override
  Future<void> connectRealtime() => _socket.connect();

  @override
  Future<void> disconnectRealtime() => _socket.disconnect();

  @override
  Future<void> joinConversation(String conversationId) async {}

  @override
  Future<void> leaveConversation(String conversationId) async {}

  @override
  Future<void> enableReceiveFromAnyone() async {}

  @override
  Future<void> disableReceiveFromAnyone() async {}

  String _previewFor(MessageDto dto) {
    if (dto.type == 'ATTACHMENT' || dto.attachments.isNotEmpty) {
      final firstTitle = dto.attachments.isNotEmpty
          ? dto.attachments.first.title
          : 'Shared content';
      return '🎵 $firstTitle';
    }
    return (dto.text ?? '').trim();
  }

  void _bumpConversationPreview({
    required String conversationId,
    required String preview,
    required DateTime at,
    required int unreadDelta,
    bool resetUnread = false,
  }) {
    final conversation = _store.conversations[conversationId];
    if (conversation == null) return;

    _store.conversations[conversationId] = ConversationDto(
      conversationId: conversation.conversationId,
      otherUser: conversation.otherUser,
      lastMessagePreview: preview,
      lastMessageAt: at,
      unreadCount: resetUnread ? 0 : conversation.unreadCount + unreadDelta,
      isBlocked: conversation.isBlocked,
    );
  }

  void _scheduleAutoReply(String conversationId) {
    final conversation = _store.conversations[conversationId];
    if (conversation == null || conversation.isBlocked) return;

    final replies = ['yo', 'haha', 'cool', 'send me a track', 'on it'];
    final reply = replies[_rng.nextInt(replies.length)];

    Timer(const Duration(seconds: 2), () {
      final dto = MessageDto(
        id: 'm${DateTime.now().microsecondsSinceEpoch}_auto',
        conversationId: conversationId,
        senderId: conversation.otherUser.id,
        type: 'TEXT',
        text: reply,
        createdAt: DateTime.now(),
        isRead: false,
      );

      _store.messages.putIfAbsent(conversationId, () => []).add(dto);
      _store.archivedConversationIds.remove(conversationId);
      _bumpConversationPreview(
        conversationId: conversationId,
        preview: reply,
        at: dto.createdAt,
        unreadDelta: 1,
      );
      _socket.emit(MessageReceivedEvent(MessagingMapper.message(dto)));
    });
  }

  String _displayNameFromUserId(String userId) {
    if (userId.trim().isEmpty) return 'User';
    return userId
        .replaceAll(RegExp(r'^u_'), '')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();
  }
}
