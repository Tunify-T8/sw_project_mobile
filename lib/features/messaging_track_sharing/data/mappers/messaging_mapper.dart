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

  static MessageAttachmentType _attachmentType(String raw) =>
      raw.toUpperCase() == 'COLLECTION'
          ? MessageAttachmentType.collection
          : MessageAttachmentType.track;

  static MessageAttachment attachment(MessageAttachmentDto d) => MessageAttachment(
        id: d.id,
        type: _attachmentType(d.type),
        title: d.title,
        artworkUrl: d.artworkUrl,
      );

  static MessageType _messageType(String raw) =>
      raw.toUpperCase() == 'ATTACHMENT' ? MessageType.attachment : MessageType.text;

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

  static PaginatedMessages messages(PaginatedDto<MessageDto> d) => PaginatedMessages(
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
