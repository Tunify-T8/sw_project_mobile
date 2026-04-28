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
    final singleAttachment = _attachmentObjectFor(j, type);
    if (singleAttachment != null &&
        _hasRealAttachment(singleAttachment, type)) {
      final att = singleAttachment;
      final merged = <String, dynamic>{...att, 'type': att['type'] ?? type};
      attachments.add(MessageAttachmentDto.fromJson(merged));
    } else if (_isAttachmentType(type)) {
      // Backend returned an attachment-type message but with no usable
      // attachment payload (e.g. collection include missing on getMessages).
      // Synthesise a placeholder so the bubble doesn't render empty.
      final fallbackTitle = _attachmentFallbackTitle(type);
      attachments.add(
        MessageAttachmentDto(id: '', type: type, title: fallbackTitle),
      );
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

  static const _attachmentTypes = {
    'TRACK',
    'TRACK_LIKE',
    'TRACK_UPLOAD',
    'UPLOAD',
    'COLLECTION',
    'PLAYLIST',
    'ALBUM',
    'USER',
  };

  static bool _isAttachmentType(String type) => _attachmentTypes.contains(type);

  static String _attachmentFallbackTitle(String type) {
    switch (type) {
      case 'TRACK_LIKE':
      case 'TRACK_UPLOAD':
      case 'UPLOAD':
      case 'TRACK':
        return 'Shared track';
      case 'COLLECTION':
      case 'PLAYLIST':
        return 'Shared playlist';
      case 'ALBUM':
        return 'Shared album';
      case 'USER':
        return 'Shared profile';
      default:
        return 'Shared content';
    }
  }

  static bool _hasRealAttachment(Map<String, dynamic> value, String type) {
    if (type == 'TEXT') return false;

    final id = _string(value['id']);
    final hasId = id.isNotEmpty && id.toLowerCase() != 'null';

    final preview = _map(value['preview']);
    final hasPreview =
        preview != null &&
        preview.values.any((v) {
          final text = _string(v);
          return text.isNotEmpty && text.toLowerCase() != 'null';
        });

    // Accept the attachment if either the id or the preview has real content.
    // This covers UPLOAD messages where id comes from collectionId and
    // preview carries title/coverUrl even when the other field is null.
    return hasId || hasPreview;
  }

  static Map<String, dynamic>? _attachmentObjectFor(
    Map<String, dynamic> json,
    String type,
  ) {
    final explicit = _map(json['attachment'] ?? json['sharedResource']);
    if (explicit != null) return explicit;

    switch (type) {
      case 'TRACK':
      case 'TRACK_LIKE':
      case 'TRACK_UPLOAD':
      case 'UPLOAD':
        return _map(json['track']);
      case 'COLLECTION':
      case 'PLAYLIST':
      case 'ALBUM':
        return _map(json['collection']);
      case 'USER':
        return _map(json['sharedUser']);
      default:
        return null;
    }
  }
}
