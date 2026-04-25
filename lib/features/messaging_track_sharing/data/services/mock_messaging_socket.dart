import 'dart:async';

import '../../domain/entities/realtime_event.dart';
import '../dto/message_dto.dart';
import 'messaging_socket.dart';

/// In-memory, no-op socket used by the mock repository.
///
/// The mock repository itself is responsible for storing conversations and
/// fanning realtime events — this class just hosts the broadcast stream and
/// tracks connection state.
class MockMessagingSocket implements MessagingSocket {
  final _controller = StreamController<RealtimeMessagingEvent>.broadcast();
  bool _connected = false;

  @override
  Stream<RealtimeMessagingEvent> get events => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async => _connected = true;

  @override
  Future<void> disconnect() async => _connected = false;

  @override
  Future<void> joinConversation(String conversationId) async {}

  @override
  Future<void> leaveConversation(String conversationId) async {}

  @override
  Future<MessageDto> sendMessage(Map<String, dynamic> payload) async {
    throw UnimplementedError(
        'MockMessagingSocket.sendMessage is not used — mock repo handles sends.');
  }

  @override
  Future<void> markMessageRead({
    required String conversationId,
    required String messageId,
  }) async {}

  @override
  void startTyping(String conversationId) {}

  @override
  void stopTyping(String conversationId) {}

  void emit(RealtimeMessagingEvent e) {
    if (_connected) _controller.add(e);
  }

  Future<void> dispose() async {
    _connected = false;
    await _controller.close();
  }
}
