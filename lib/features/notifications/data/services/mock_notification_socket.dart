import 'dart:async';

import '../../domain/entities/notification_entity.dart';
import 'notification_socket.dart';

/// No-op socket used in mock mode.
/// The mock store's broadcast stream is wired directly by the controller
/// instead — this class just satisfies the interface.
class MockNotificationSocket implements NotificationSocket {
  final _controller = StreamController<NotificationEntity>.broadcast();
  bool _connected = false;

  @override
  Stream<NotificationEntity> get notifications => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async => _connected = true;

  @override
  Future<void> disconnect() async => _connected = false;

  void dispose() {
    _connected = false;
    _controller.close();
  }
}
