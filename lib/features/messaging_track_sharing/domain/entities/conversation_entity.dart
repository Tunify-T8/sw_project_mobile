import 'user_preview.dart';

class ConversationEntity {
  final String conversationId;
  final UserPreview otherUser;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;

  /// Sender id of the most recent message in this conversation, when known.
  /// The conversation tile uses this to avoid showing an "unread" highlight
  /// for conversations where the last message was sent by the current user.
  final String? lastMessageSenderId;
  final int unreadCount;
  final bool isBlocked;
  final bool isArchived;

  const ConversationEntity({
    required this.conversationId,
    required this.otherUser,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.unreadCount = 0,
    this.isBlocked = false,
    this.isArchived = false,
  });

  ConversationEntity copyWith({
    UserPreview? otherUser,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    String? lastMessageSenderId,
    int? unreadCount,
    bool? isBlocked,
    bool? isArchived,
  }) => ConversationEntity(
    conversationId: conversationId,
    otherUser: otherUser ?? this.otherUser,
    lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
    unreadCount: unreadCount ?? this.unreadCount,
    isBlocked: isBlocked ?? this.isBlocked,
    isArchived: isArchived ?? this.isArchived,
  );
}
