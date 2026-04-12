import 'user_preview_dto.dart';

class ConversationDto {
  final String conversationId;
  final UserPreviewDto otherUser;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isBlocked;

  const ConversationDto({
    required this.conversationId,
    required this.otherUser,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isBlocked = false,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> j) => ConversationDto(
        conversationId: (j['conversationId'] ?? '').toString(),
        otherUser: UserPreviewDto.fromJson(
            (j['otherUser'] as Map<String, dynamic>?) ?? const {}),
        lastMessagePreview: j['lastMessagePreview'] as String?,
        lastMessageAt: j['lastMessageAt'] == null
            ? null
            : DateTime.tryParse(j['lastMessageAt'].toString()),
        unreadCount: (j['unreadCount'] as int?) ?? 0,
        isBlocked: (j['isBlocked'] as bool?) ?? false,
      );
}
