import '../../domain/entities/notification_entity.dart';

/// Abstraction over the realtime transport for notifications.
abstract class NotificationSocket {
  Stream<NotificationEntity> get notifications;
  Future<void> connect();
  Future<void> disconnect();
  bool get isConnected;
}
