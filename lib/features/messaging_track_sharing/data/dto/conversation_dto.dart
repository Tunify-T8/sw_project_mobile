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
    final id = (j['id'] ?? j['conversationId'] ?? '').toString();
    final user1 = (j['user1Id'] ?? '').toString();
    final user2 = (j['user2Id'] ?? '').toString();
    final status = (j['status'] ?? 'ACTIVE').toString().toUpperCase();

    String otherUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      otherUserId = user1.isNotEmpty ? user1 : user2;
    } else {
      otherUserId = user1 == currentUserId ? user2 : user1;
    }

    // Prefer a nested preview when the backend includes one.
    UserPreviewDto other;
    final otherUserJson = j['otherUser'];
    if (otherUserJson is Map<String, dynamic>) {
      other = UserPreviewDto.fromJson(otherUserJson);
    } else if (userPreviewResolver != null && otherUserId.isNotEmpty) {
      other = userPreviewResolver(otherUserId);
    } else {
      other = UserPreviewDto(
        id: otherUserId,
        displayName: otherUserId,
      );
    }

    MessageDto? lastMessage;
    if (j['lastMessage'] is Map<String, dynamic>) {
      lastMessage = MessageDto.fromJson(
        j['lastMessage'] as Map<String, dynamic>,
        fallbackConversationId: id,
      );
    }

    String? lastPreview = j['lastMessagePreview'] as String?;
    DateTime? lastAt = j['lastMessageAt'] == null
        ? null
        : DateTime.tryParse(j['lastMessageAt'].toString());

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
      unreadCount: (j['unreadCount'] as int?) ?? 0,
      isBlocked:
          status == 'BLOCKED' || ((j['isBlocked'] as bool?) ?? false),
      lastMessage: lastMessage,
    );
  }

  static String _previewFor(MessageDto m) {
    if (m.type == 'TEXT') return (m.text ?? '').trim();
    if (m.attachments.isNotEmpty) {
      final title = m.attachments.first.title;
      return title.isEmpty ? 'Shared content' : '🎵 $title';
    }
    return 'Shared content';
  }
}
