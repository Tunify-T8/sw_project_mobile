import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/notification_entity.dart';
import '../dto/notification_dto.dart';
import '../mappers/notification_mapper.dart';
import 'notification_socket.dart';

/// Connects to the backend Socket.IO notifications namespace.
///
/// Backend: @WebSocketGateway({ namespace: '/notifications' })
/// Auth:    socket.handshake.query.token  ← JWT access token
/// Event:   'notification'  ← server emits this with the notification payload
class RealNotificationSocket implements NotificationSocket {
  RealNotificationSocket(this._tokenStorage);

  final TokenStorage _tokenStorage;

  io.Socket? _socket;
  final _controller = StreamController<NotificationEntity>.broadcast();
  bool _connected = false;

  static String get _wsBaseUrl {
    // Strip /api suffix — socket server lives at the domain root.
    final base = ApiEndpoints.baseUrl;
    if (base.endsWith('/api')) {
      return base.substring(0, base.length - 4);
    }
    return base;
  }

  @override
  Stream<NotificationEntity> get notifications => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    if (_connected) return;

    final token = await _tokenStorage.getAccessToken();
    if (token == null) {
      debugPrint('[NotificationSocket] No access token — skipping connect');
      return;
    }

    // Namespace is appended to the URL, not set via OptionBuilder in v2.
    _socket = io.io(
      '$_wsBaseUrl/notifications',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      _connected = true;
      debugPrint('[NotificationSocket] connected');
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      debugPrint('[NotificationSocket] disconnected');
    });

    _socket!.onConnectError((err) {
      _connected = false;
      debugPrint('[NotificationSocket] connect error: $err');
    });

    _socket!.on('notification', (data) {
      try {
        final map = Map<String, dynamic>.from(data as Map);
        final dto = NotificationDto.fromJson(map);
        final entity = NotificationMapper.notification(dto);
        _controller.add(entity);
      } catch (e) {
        debugPrint('[NotificationSocket] parse error: $e');
      }
    });

    _socket!.connect();
  }

  @override
  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connected = false;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
