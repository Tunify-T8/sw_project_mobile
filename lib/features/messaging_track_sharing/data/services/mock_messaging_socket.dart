import 'dart:async';
import '../../domain/entities/realtime_event.dart';
import 'messaging_socket.dart';

class MockMessagingSocket implements MessagingSocket {
  final _controller = StreamController<RealtimeMessagingEvent>.broadcast();
  bool _connected = false;
  @override Stream<RealtimeMessagingEvent> get events => _controller.stream;
  @override bool get isConnected => _connected;
  @override Future<void> connect() async => _connected = true;
  @override Future<void> disconnect() async => _connected = false;
  void emit(RealtimeMessagingEvent e) { if (_connected) _controller.add(e); }
  Future<void> dispose() async { _connected = false; await _controller.close(); }
}
