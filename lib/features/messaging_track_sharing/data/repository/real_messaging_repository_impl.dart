import '../../domain/entities/message_attachment.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/paginated_conversations.dart';
import '../../domain/entities/paginated_messages.dart';
import '../../domain/entities/realtime_event.dart';
import '../../domain/entities/send_message_draft.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../api/messaging_api.dart';
import '../mappers/messaging_mapper.dart';
import '../services/messaging_socket.dart';

/// Real backend-backed implementation.
///
/// REST is used for history, unread count, archive, block, delete.
/// Realtime and *sending* go through [MessagingSocket].
class RealMessagingRepository implements MessagingRepository {
  RealMessagingRepository(
    this._api,
    this._socket, {
    required this.currentUserId,
  });

  final MessagingApi _api;
  final MessagingSocket _socket;

  /// Getter for the current signed-in user's id. Conversation DTOs don't
  /// denormalize the "other user" so we need this to resolve who that is.
  final String? Function() currentUserId;

  @override
  Future<PaginatedConversations> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final paginated = await _api.getConversations(
      page: page,
      limit: limit,
      currentUserId: currentUserId(),
    );
    return MessagingMapper.conversations(paginated);
  }

  @override
  Future<String> createOrGetConversation(String otherUserId) =>
      _api.createOrGetConversation(otherUserId);

  @override
  Future<void> deleteConversation(String conversationId) =>
      _api.deleteConversation(conversationId);

  @override
  Future<PaginatedMessages> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async =>
      MessagingMapper.messages(
        await _api.getMessages(conversationId, page: page, limit: limit),
      );

  @override
  Future<MessageEntity> sendMessage(
    String conversationId,
    SendMessageDraft draft,
  ) async {
    // The backend models messages polymorphically — one `type` per message
    // with a type-specific fk. Attachments that arrive as a list from the UI
    // are sent as separate messages (text goes out as a TEXT message first).
    final trimmedText = (draft.text ?? '').trim();
    final hasText = trimmedText.isNotEmpty;
    final attachments = draft.attachments;

    if (!hasText && attachments.isEmpty) {
      throw ArgumentError('Cannot send an empty message.');
    }

    MessageEntity? last;

    if (hasText) {
      last = MessagingMapper.message(
        await _socket.sendMessage(<String, dynamic>{
          'conversationId': conversationId,
          'type': 'TEXT',
          'content': trimmedText,
        }),
      );
    }

    for (final attachment in attachments) {
      final kind = attachment.backendKind;
      final payload = <String, dynamic>{
        'conversationId': conversationId,
        'type': kind.wireType,
      };
      switch (kind) {
        case MessageAttachmentBackendKind.trackLike:
        case MessageAttachmentBackendKind.trackUpload:
          payload['trackId'] = attachment.id;
          break;
        case MessageAttachmentBackendKind.playlist:
        case MessageAttachmentBackendKind.album:
          payload['collectionId'] = attachment.id;
          break;
        case MessageAttachmentBackendKind.user:
          payload['userId'] = attachment.id;
          break;
      }
      last = MessagingMapper.message(await _socket.sendMessage(payload));
    }

    return last!;
  }

  @override
  Future<void> markConversationRead(String conversationId) =>
      _api.markRead(conversationId);

  @override
  Future<int> getUnreadCount() => _api.getUnreadCount();

  @override
  Future<void> blockConversation(String conversationId) =>
      _api.block(conversationId);

  @override
  Future<void> joinConversation(String conversationId) =>
      _socket.joinConversation(conversationId);

  @override
  Future<void> leaveConversation(String conversationId) =>
      _socket.leaveConversation(conversationId);

  @override
  Stream<RealtimeMessagingEvent> realtimeEvents() => _socket.events;

  @override
  Future<void> connectRealtime() => _socket.connect();

  @override
  Future<void> disconnectRealtime() => _socket.disconnect();
}
