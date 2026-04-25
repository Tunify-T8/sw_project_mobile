import '../../domain/entities/realtime_event.dart';
import '../dto/message_dto.dart';

/// Abstraction over the realtime transport for messaging (WebSocket / mock).
///
/// Sending messages is a socket operation — so is joining and leaving
/// conversation rooms. REST is only used for the things the backend didn't
/// move onto the websocket (history fetch, unread count, block/archive, etc).
abstract class MessagingSocket {
  Stream<RealtimeMessagingEvent> get events;
  bool get isConnected;

  Future<void> connect();
  Future<void> disconnect();

  Future<void> joinConversation(String conversationId);
  Future<void> leaveConversation(String conversationId);

  /// Fires `message:send` and resolves with the full message DTO once the
  /// server broadcasts it back (or when `message:sent` acks and the optimistic
  /// echo can be constructed locally).
  Future<MessageDto> sendMessage(Map<String, dynamic> payload);

  /// Fires `message:markRead` for a specific message id.
  Future<void> markMessageRead({
    required String conversationId,
    required String messageId,
  });

  void startTyping(String conversationId);
  void stopTyping(String conversationId);
}
