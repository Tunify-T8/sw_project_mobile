import 'user_preview.dart';

class ConversationEntity {
  final String conversationId;
  final UserPreview otherUser;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isBlocked;
  final bool isArchived;

  const ConversationEntity({
    required this.conversationId,
    required this.otherUser,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isBlocked = false,
    this.isArchived = false,
  });

  ConversationEntity copyWith({
    UserPreview? otherUser,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isBlocked,
    bool? isArchived,
  }) => ConversationEntity(
    conversationId: conversationId,
    otherUser: otherUser ?? this.otherUser,
    lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    unreadCount: unreadCount ?? this.unreadCount,
    isBlocked: isBlocked ?? this.isBlocked,
    isArchived: isArchived ?? this.isArchived,
  );
}
