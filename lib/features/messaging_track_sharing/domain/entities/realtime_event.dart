import 'message_entity.dart';

/// Events streamed from the messaging socket.
sealed class RealtimeMessagingEvent {
  const RealtimeMessagingEvent();
}

class MessageReceivedEvent extends RealtimeMessagingEvent {
  final MessageEntity message;
  const MessageReceivedEvent(this.message);
}

class MessageReadEvent extends RealtimeMessagingEvent {
  final String conversationId;
  final String? messageId;
  final String readerUserId;
  const MessageReadEvent({
    required this.conversationId,
    required this.readerUserId,
    this.messageId,
  });
}

class MessageDeliveredEvent extends RealtimeMessagingEvent {
  final String conversationId;
  final String? messageId;
  final String readerUserId;
  const MessageDeliveredEvent({
    required this.conversationId,
    required this.readerUserId,
    this.messageId,
  });
}

class MessageUndeliveredEvent extends RealtimeMessagingEvent {
  final String conversationId;
  final String? messageId;
  const MessageUndeliveredEvent({required this.conversationId, this.messageId});
}

class ConversationBlockedEvent extends RealtimeMessagingEvent {
  final String conversationId;
  const ConversationBlockedEvent(this.conversationId);
}

class TypingEvent extends RealtimeMessagingEvent {
  final String conversationId;
  final String userId;
  final bool isTyping;
  const TypingEvent({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });
}
