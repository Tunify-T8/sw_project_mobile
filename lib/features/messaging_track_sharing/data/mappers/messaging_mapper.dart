import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_attachment.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/paginated_conversations.dart';
import '../../domain/entities/paginated_messages.dart';
import '../../domain/entities/user_preview.dart';
import '../dto/conversation_dto.dart';
import '../dto/message_attachment_dto.dart';
import '../dto/message_dto.dart';
import '../dto/paginated_dto.dart';
import '../dto/user_preview_dto.dart';

/// Pure functions — one-way DTO -> entity conversions.
class MessagingMapper {
  const MessagingMapper._();

  static UserPreview userPreview(UserPreviewDto d) =>
      UserPreview(id: d.id, displayName: d.displayName, avatarUrl: d.avatarUrl);

  static MessageAttachment attachment(MessageAttachmentDto d) {
    final backendKind =
        MessageAttachmentBackendKindX.fromWire(d.type);

    MessageAttachmentType uiType;
    if (backendKind != null) {
      uiType = backendKind.uiType;
    } else {
      switch (d.type.toUpperCase()) {
        case 'COLLECTION':
          uiType = MessageAttachmentType.collection;
          break;
        case 'USER':
          uiType = MessageAttachmentType.user;
          break;
        case 'TRACK':
        default:
          uiType = MessageAttachmentType.track;
      }
    }

    return MessageAttachment(
      id: d.id,
      type: uiType,
      backendKind: backendKind,
      title: d.title,
      subtitle: d.subtitle,
      artworkUrl: d.artworkUrl,
    );
  }

  static MessageType _messageType(String raw) {
    switch (raw.toUpperCase()) {
      case 'TEXT':
        return MessageType.text;
      case 'ATTACHMENT':
      case 'TRACK_LIKE':
      case 'TRACK_UPLOAD':
      case 'PLAYLIST':
      case 'ALBUM':
      case 'USER':
      default:
        return MessageType.attachment;
    }
  }

  static MessageEntity message(MessageDto d) => MessageEntity(
        id: d.id,
        conversationId: d.conversationId,
        senderId: d.senderId,
        type: _messageType(d.type),
        text: d.text,
        attachments: d.attachments.map(attachment).toList(),
        createdAt: d.createdAt,
        isRead: d.isRead,
      );

  static ConversationEntity conversation(ConversationDto d) => ConversationEntity(
        conversationId: d.conversationId,
        otherUser: userPreview(d.otherUser),
        lastMessagePreview: d.lastMessagePreview,
        lastMessageAt: d.lastMessageAt,
        unreadCount: d.unreadCount,
        isBlocked: d.isBlocked,
      );

  static PaginatedMessages messages(PaginatedDto<MessageDto> d) =>
      PaginatedMessages(
        items: d.items.map(message).toList(),
        page: d.page,
        limit: d.limit,
        total: d.total,
      );

  static PaginatedConversations conversations(PaginatedDto<ConversationDto> d) =>
      PaginatedConversations(
        items: d.items.map(conversation).toList(),
        page: d.page,
        limit: d.limit,
        total: d.total,
      );
}
