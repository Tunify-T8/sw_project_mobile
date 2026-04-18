import 'message_attachment_dto.dart';

class MessageDto {
  final String id;
  final String conversationId;
  final String senderId;
  final String type; // TEXT | ATTACHMENT
  final String? text;
  final DateTime createdAt;
  final bool isRead;
  final List<MessageAttachmentDto> attachments;

  const MessageDto({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.createdAt,
    this.text,
    this.isRead = false,
    this.attachments = const [],
  });

  factory MessageDto.fromJson(Map<String, dynamic> j, {String? fallbackConversationId}) {
    final atts = (j['attachments'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(MessageAttachmentDto.fromJson)
            .toList() ??
        const <MessageAttachmentDto>[];

    return MessageDto(
      id: (j['id'] ?? '').toString(),
      conversationId:
          (j['conversationId'] ?? fallbackConversationId ?? '').toString(),
      senderId: (j['senderId'] ?? '').toString(),
      type: (j['type'] ?? 'TEXT').toString().toUpperCase(),
      text: j['text'] as String?,
      createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ??
          DateTime.now().toUtc(),
      isRead: (j['isRead'] as bool?) ?? false,
      attachments: atts,
    );
  }
}
