import 'user_preview.dart';

class ConversationEntity {
  final String conversationId;
  final UserPreview otherUser;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isBlocked;

  const ConversationEntity({
    required this.conversationId,
    required this.otherUser,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isBlocked = false,
  });

  ConversationEntity copyWith({
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isBlocked,
  }) => ConversationEntity(
        conversationId: conversationId,
        otherUser: otherUser,
        lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        isBlocked: isBlocked ?? this.isBlocked,
      );
}
