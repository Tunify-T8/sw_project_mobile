import 'message_attachment.dart';

enum MessageType { text, attachment }

enum MessageDeliveryStatus { sent, delivered, read }

/// Domain entity representing a single chat message.
class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final MessageType type;
  final String? text;
  final List<MessageAttachment> attachments;
  final DateTime createdAt;
  final bool isRead;
  final MessageDeliveryStatus deliveryStatus;

  /// True for messages the current user is optimistically sending (not yet confirmed).
  final bool isPending;

  /// True when delivery failed (socket/API error).
  final bool isFailed;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.createdAt,
    this.text,
    this.attachments = const [],
    bool isRead = false,
    this.deliveryStatus = MessageDeliveryStatus.sent,
    this.isPending = false,
    this.isFailed = false,
  }) : isRead = isRead || deliveryStatus == MessageDeliveryStatus.read;

  MessageEntity copyWith({
    String? id,
    bool? isRead,
    MessageDeliveryStatus? deliveryStatus,
    bool? isPending,
    bool? isFailed,
  }) => MessageEntity(
    id: id ?? this.id,
    conversationId: conversationId,
    senderId: senderId,
    type: type,
    createdAt: createdAt,
    text: text,
    attachments: attachments,
    isRead: isRead ?? this.isRead,
    deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    isPending: isPending ?? this.isPending,
    isFailed: isFailed ?? this.isFailed,
  );
}
