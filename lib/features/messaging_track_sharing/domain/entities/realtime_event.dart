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
  final String readerUserId;
  const MessageReadEvent({required this.conversationId, required this.readerUserId});
}

class ConversationBlockedEvent extends RealtimeMessagingEvent {
  final String conversationId;
  const ConversationBlockedEvent(this.conversationId);
}
