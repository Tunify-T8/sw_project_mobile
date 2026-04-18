import '../../domain/entities/realtime_event.dart';

/// Abstraction over the realtime transport (WebSocket / mock bus).
abstract class MessagingSocket {
  Stream<RealtimeMessagingEvent> get events;
  Future<void> connect();
  Future<void> disconnect();
  bool get isConnected;
}
