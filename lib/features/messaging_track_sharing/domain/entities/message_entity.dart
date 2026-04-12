import 'message_attachment.dart';

enum MessageType { text, attachment }

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
    this.isRead = false,
    this.isPending = false,
    this.isFailed = false,
  });

  MessageEntity copyWith({
    String? id,
    bool? isRead,
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
        isPending: isPending ?? this.isPending,
        isFailed: isFailed ?? this.isFailed,
      );
}
