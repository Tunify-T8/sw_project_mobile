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

  factory MessageDto.fromJson(
    Map<String, dynamic> j, {
    String? fallbackConversationId,
  }) {
    final sender =
        _map(j['sender'] ?? j['from'] ?? j['user']) ??
        const <String, dynamic>{};

    final senderId = _firstNonEmpty([
      j['senderId'],
      j['sender_id'],
      j['fromUserId'],
      j['from_user_id'],
      j['userId'],
      sender['id'],
      sender['_id'],
      sender['userId'],
      sender['user_id'],
    ]);
    final senderDisplay = _nullableString(
      sender['displayName'] ??
          sender['display_name'] ??
          sender['username'] ??
          sender['userName'] ??
          sender['name'],
    );
    final senderAvatar = _nullableString(
      sender['avatarUrl'] ??
          sender['avatar_url'] ??
          sender['profileImagePath'] ??
          sender['profile_image_path'],
    );

    final type =
        (j['type'] ?? (j['attachment'] != null ? 'ATTACHMENT' : 'TEXT'))
            .toString()
            .toUpperCase();

    final text = _nullableString(j['text'] ?? j['content'] ?? j['body']);

    // Backend may send a single attachment under `attachment`, older /
    // optimistic payloads use the flat `attachments` list.
    final attachments = <MessageAttachmentDto>[];
    final singleAttachment = _map(j['attachment'] ?? j['sharedResource']);
    if (singleAttachment != null) {
      final att = singleAttachment;
      // Propagate outer type into the attachment so the mapper can route
      // the UI correctly even if `att.type` is absent.
      final merged = <String, dynamic>{...att, 'type': att['type'] ?? type};
      attachments.add(MessageAttachmentDto.fromJson(merged));
    } else {
      final list = (j['attachments'] as List?) ?? const [];
      attachments.addAll(
        list.whereType<Map<String, dynamic>>().map(
          MessageAttachmentDto.fromJson,
        ),
      );
    }

    return MessageDto(
      id: _string(j['id'] ?? j['_id'] ?? j['messageId'] ?? j['message_id']),
      conversationId: _string(
        j['conversationId'] ?? j['conversation_id'] ?? fallbackConversationId,
      ),
      senderId: senderId,
      senderDisplayName: senderDisplay,
      senderAvatarUrl: senderAvatar,
      type: type,
      text: text,
      createdAt:
          DateTime.tryParse((j['createdAt'] ?? '').toString()) ??
          DateTime.now().toUtc(),
      isRead: (j['read'] as bool?) ?? (j['isRead'] as bool?) ?? false,
      attachments: attachments,
    );
  }

  static String _string(Object? value) => value?.toString().trim() ?? '';

  static String? _nullableString(Object? value) {
    final text = _string(value);
    return text.isEmpty ? null : text;
  }

  static String _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final text = _string(value);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static Map<String, dynamic>? _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }
}
