import 'message_attachment_dto.dart';

/// Wire-level representation of a chat message.
///
/// The backend is polymorphic: a message has exactly one `type` of
/// TEXT | TRACK_LIKE | TRACK_UPLOAD | PLAYLIST | ALBUM | USER.
/// Non-TEXT messages come with an `attachment` object (and a type-specific
/// foreign key field: `trackId`, `collectionId`, `userId`).
///
/// For convenience higher layers continue to see the old flat list
/// [attachments] with a single entry when the message is non-TEXT.
class MessageDto {
  final String id;
  final String conversationId;
  final String senderId;
  final String? senderDisplayName;
  final String? senderAvatarUrl;

  /// Raw backend type, upper-cased.
  /// TEXT | TRACK_LIKE | TRACK_UPLOAD | PLAYLIST | ALBUM | USER | ATTACHMENT.
  final String type;
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
    this.senderDisplayName,
    this.senderAvatarUrl,
    this.text,
    this.isRead = false,
    this.attachments = const [],
  });

  factory MessageDto.fromJson(Map<String, dynamic> j,
      {String? fallbackConversationId}) {
    final sender = (j['sender'] is Map<String, dynamic>)
        ? j['sender'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final senderId = (j['senderId'] ?? sender['id'] ?? '').toString();
    final senderDisplay =
        (sender['username'] ?? sender['displayName']) as String?;
    final senderAvatar = sender['avatarUrl'] as String?;

    final type =
        (j['type'] ?? (j['attachment'] != null ? 'ATTACHMENT' : 'TEXT'))
            .toString()
            .toUpperCase();

    final text = (j['text'] ?? j['content']) as String?;

    // Backend may send a single attachment under `attachment`, older /
    // optimistic payloads use the flat `attachments` list.
    final attachments = <MessageAttachmentDto>[];
    if (j['attachment'] is Map<String, dynamic>) {
      final att = j['attachment'] as Map<String, dynamic>;
      // Propagate outer type into the attachment so the mapper can route
      // the UI correctly even if `att.type` is absent.
      final merged = <String, dynamic>{...att, 'type': att['type'] ?? type};
      attachments.add(MessageAttachmentDto.fromJson(merged));
    } else {
      final list = (j['attachments'] as List?) ?? const [];
      attachments.addAll(list
          .whereType<Map<String, dynamic>>()
          .map(MessageAttachmentDto.fromJson));
    }

    return MessageDto(
      id: (j['id'] ?? '').toString(),
      conversationId:
          (j['conversationId'] ?? fallbackConversationId ?? '').toString(),
      senderId: senderId,
      senderDisplayName: senderDisplay,
      senderAvatarUrl: senderAvatar,
      type: type,
      text: text,
      createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ??
          DateTime.now().toUtc(),
      isRead: (j['read'] as bool?) ?? (j['isRead'] as bool?) ?? false,
      attachments: attachments,
    );
  }
}
