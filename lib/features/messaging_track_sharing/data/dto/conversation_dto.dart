import 'message_dto.dart';
import 'user_preview_dto.dart';

/// Wire-level representation of a 1-to-1 conversation.
///
/// The backend returns the two participant ids (`user1Id`, `user2Id`) plus a
/// `status` (ACTIVE | ARCHIVED | BLOCKED) and a nullable `lastMessage` DTO.
///
/// The repository layer is responsible for resolving which of the two users
/// is the "other user" relative to the current signed-in user and for
/// fetching / caching their [UserPreviewDto].
class ConversationDto {
  final String conversationId;

  /// Backend ids — may be empty in mock mode.
  final String user1Id;
  final String user2Id;

  final UserPreviewDto otherUser;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isBlocked;

  /// Last message DTO straight from the backend, if present.
  /// The mapper uses this to build the preview text when we don't yet
  /// know it.
  final MessageDto? lastMessage;

  const ConversationDto({
    required this.conversationId,
    required this.otherUser,
    this.user1Id = '',
    this.user2Id = '',
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isBlocked = false,
    this.lastMessage,
  });

  /// Parses the backend conversation payload.
  ///
  /// Because the backend does not denormalize the "other user" on the
  /// response, callers pass [currentUserId] and optionally [userPreviewResolver]
  /// to turn the raw participant id into a [UserPreviewDto].
  factory ConversationDto.fromJson(
    Map<String, dynamic> j, {
    String? currentUserId,
    UserPreviewDto Function(String userId)? userPreviewResolver,
  }) {
    final id = _string(j['id'] ?? j['_id'] ?? j['conversationId']);
    final participants = _participantMaps(j);
    final user1 = _firstNonEmpty([
      j['user1Id'],
      j['user1_id'],
      j['userOneId'],
      j['participant1Id'],
      j['participantOneId'],
      _idFromMap(_map(j['user1'])),
      _idFromMap(_map(j['userOne'])),
      participants.isNotEmpty ? _idFromMap(participants.first) : null,
    ]);
    final user2 = _firstNonEmpty([
      j['user2Id'],
      j['user2_id'],
      j['userTwoId'],
      j['participant2Id'],
      j['participantTwoId'],
      _idFromMap(_map(j['user2'])),
      _idFromMap(_map(j['userTwo'])),
      participants.length > 1 ? _idFromMap(participants[1]) : null,
    ]);
    final status = (j['status'] ?? 'ACTIVE').toString().toUpperCase();

    String otherUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      otherUserId = _firstNonEmpty([
        j['otherUserId'],
        j['recipientId'],
        j['receiverId'],
        j['targetUserId'],
        user1,
        user2,
      ]);
    } else {
      otherUserId = user1 == currentUserId ? user2 : user1;
      if (otherUserId.isEmpty) {
        otherUserId = _idFromMap(
          _firstOtherParticipant(participants, currentUserId),
        );
      }
    }

    // Prefer a nested preview when the backend includes one.
    UserPreviewDto other;
    final otherUserJson = _firstMap([
      j['otherUser'],
      j['other_user'],
      j['recipient'],
      j['receiver'],
      j['targetUser'],
      j['user'],
      participants.cast<Object?>().firstWhere(
        (p) => _idFromMap(_map(p)) == otherUserId,
        orElse: () => null,
      ),
    ]);
    if (otherUserJson != null) {
      final withId = <String, dynamic>{
        if (otherUserId.isNotEmpty) 'id': otherUserId,
        ...otherUserJson,
      };
      other = UserPreviewDto.fromJson(withId);
    } else if (userPreviewResolver != null && otherUserId.isNotEmpty) {
      other = userPreviewResolver(otherUserId);
    } else {
      other = UserPreviewDto(
        id: otherUserId,
        displayName: otherUserId.isNotEmpty
            ? _friendlyDisplayName(otherUserId)
            : 'Unknown User',
      );
    }

    MessageDto? lastMessage;
    final lastMessageJson = _map(j['lastMessage'] ?? j['last_message']);
    if (lastMessageJson != null) {
      lastMessage = MessageDto.fromJson(
        lastMessageJson,
        fallbackConversationId: id,
      );
    }

    String? lastPreview = _nullableString(
      j['lastMessagePreview'] ?? j['last_message_preview'] ?? j['preview'],
    );
    DateTime? lastAt = j['lastMessageAt'] == null
        ? null
        : DateTime.tryParse(j['lastMessageAt'].toString());
    lastAt ??= j['last_message_at'] == null
        ? null
        : DateTime.tryParse(j['last_message_at'].toString());

    if (lastMessage != null) {
      lastAt ??= lastMessage.createdAt;
      if (lastPreview == null || lastPreview.trim().isEmpty) {
        lastPreview = _previewFor(lastMessage);
      }
    }

    lastAt ??= j['updatedAt'] == null
        ? null
        : DateTime.tryParse(j['updatedAt'].toString());

    return ConversationDto(
      conversationId: id,
      user1Id: user1,
      user2Id: user2,
      otherUser: other,
      lastMessagePreview: lastPreview,
      lastMessageAt: lastAt,
      unreadCount: _int(
        j['unreadCount'] ?? j['unread_count'] ?? j['unreadMessages'],
      ),
      isBlocked: status == 'BLOCKED' || ((j['isBlocked'] as bool?) ?? false),
      lastMessage: lastMessage,
    );
  }

  static String _previewFor(MessageDto m) {
    if (m.type == 'TEXT') return (m.text ?? '').trim();
    if (m.attachments.isNotEmpty) {
      final title = m.attachments.first.title;
      return title.isEmpty ? 'Shared content' : 'Music: $title';
    }
    return 'Shared content';
  }

  static String _string(Object? value) => value?.toString().trim() ?? '';

  static String? _nullableString(Object? value) {
    final text = _string(value);
    return text.isEmpty ? null : text;
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(_string(value)) ?? 0;
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

  static Map<String, dynamic>? _firstMap(List<Object?> values) {
    for (final value in values) {
      final map = _map(value);
      if (map != null) return map;
    }
    return null;
  }

  static List<Map<String, dynamic>> _participantMaps(Map<String, dynamic> j) {
    final raw =
        (j['participants'] as List?) ?? (j['users'] as List?) ?? const [];
    return raw
        .map(_map)
        .whereType<Map<String, dynamic>>()
        .map((p) => _map(p['user'] ?? p['profile']) ?? p)
        .toList();
  }

  static Map<String, dynamic>? _firstOtherParticipant(
    List<Map<String, dynamic>> participants,
    String currentUserId,
  ) {
    for (final participant in participants) {
      if (_idFromMap(participant) != currentUserId) return participant;
    }
    return null;
  }

  static String _idFromMap(Map<String, dynamic>? value) {
    final nested = _map(value?['user'] ?? value?['profile']);
    return _firstNonEmpty([
      value?['id'],
      value?['_id'],
      value?['userId'],
      value?['user_id'],
      nested?['id'],
      nested?['_id'],
      nested?['userId'],
      nested?['user_id'],
    ]);
  }

  static String _friendlyDisplayName(String raw) {
    final emailName = raw.contains('@') ? raw.split('@').first : raw;
    final cleaned = emailName.replaceAll(RegExp(r'[_:-]+'), ' ').trim();
    if (cleaned.isEmpty) return raw;
    return cleaned
        .split(RegExp(r'\s+'))
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}
