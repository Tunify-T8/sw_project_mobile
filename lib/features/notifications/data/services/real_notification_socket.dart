import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/notification_entity.dart';
import '../dto/notification_dto.dart';
import '../mappers/notification_mapper.dart';
import 'notification_socket.dart';

/// Connects to the backend Socket.IO `/notifications` namespace.
///
/// Backend lives behind Caddy:
///   handle /socket.io* { reverse_proxy backend:3000 }
///
/// In `socket_io_client` (Dart) the namespace is taken from the URL path —
/// the same form as the JS client used by the web frontend:
///   io('https://tunify.duckdns.org/notifications', { transports: ['websocket'] })
///
/// The library handles port `0` (default HTTPS) internally and rewrites it to
/// 443 before opening the socket. Any `:0` you see in error messages is a
/// purely cosmetic side-effect of `dart:io`'s WebSocket exception formatter.
class RealNotificationSocket implements NotificationSocket {
  RealNotificationSocket(this._tokenStorage);

  final TokenStorage _tokenStorage;

  static const String _socketUrl = String.fromEnvironment(
    'NOTIFICATION_WS_URL',
    defaultValue: 'https://tunify.duckdns.org/notifications',
  );

  io.Socket? _socket;
  final _controller = StreamController<NotificationEntity>.broadcast();

  bool _connected = false;
  bool _connecting = false;
  bool _disposed = false;
  int _reconnectAttempt = 0;
  Timer? _manualReconnectTimer;
  Timer? _tokenRefreshTimer;

  @override
  Stream<NotificationEntity> get notifications => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    if (_connected || _connecting || _disposed) return;
    _connecting = true;

    try {
      final token = await _freshAccessToken();
      if (token == null || token.isEmpty) {
        debugPrint('[NotificationSocket] No access token');
        return;
      }
      _openSocket(token);
      _scheduleTokenRefresh(token);
    } finally {
      _connecting = false;
    }
  }

  @override
  Future<void> disconnect() async {
    _manualReconnectTimer?.cancel();
    _tokenRefreshTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connected = false;
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _controller.close();
  }

  void _openSocket(String token) {
    _manualReconnectTimer?.cancel();
    _socket?.dispose();

    debugPrint('[NotificationSocket] connecting to $_socketUrl');

    _socket = io.io(
      _socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .setQuery({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(20)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );

    _socket!.onConnect((_) {
      _connected = true;
      _reconnectAttempt = 0;
      debugPrint('[NotificationSocket] connected');
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      debugPrint('[NotificationSocket] disconnected');
      _scheduleManualReconnect();
    });

    _socket!.onConnectError((err) {
      _connected = false;
      debugPrint('[NotificationSocket] connect error: ${_safeError(err)}');
      _scheduleManualReconnect();
    });

    _socket!.onError((err) {
      debugPrint('[NotificationSocket] socket error: ${_safeError(err)}');
    });

    _socket!.on('authenticated', (_) {
      debugPrint('[NotificationSocket] authenticated');
    });

    _socket!.on('notification', (data) {
      try {
        final map = _notificationPayload(data);
        final dto = NotificationDto.fromJson(map);
        _controller.add(NotificationMapper.notification(dto));
      } catch (e) {
        debugPrint('[NotificationSocket] parse error: $e');
      }
    });

    _socket!.connect();
  }

  Future<void> _reconnect({bool forceRefresh = false}) async {
    if (_disposed || _connecting) return;
    _connecting = true;
    try {
      _connected = false;
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;

      final token = await _freshAccessToken(forceRefresh: forceRefresh);
      if (token == null || token.isEmpty || _disposed) return;

      _openSocket(token);
      _scheduleTokenRefresh(token);
    } finally {
      _connecting = false;
    }
  }

  void _scheduleManualReconnect({bool forceRefresh = false}) {
    if (_disposed || _connected || _manualReconnectTimer?.isActive == true) {
      return;
    }
    final seconds = (1 << _reconnectAttempt).clamp(1, 30).toInt();
    _reconnectAttempt = (_reconnectAttempt + 1).clamp(0, 5).toInt();
    _manualReconnectTimer = Timer(Duration(seconds: seconds), () {
      unawaited(_reconnect(forceRefresh: forceRefresh));
    });
  }

  void _scheduleTokenRefresh(String token) {
    _tokenRefreshTimer?.cancel();
    final expiresAt = _jwtExpiry(token);
    if (expiresAt == null) return;
    final refreshAt = expiresAt.subtract(const Duration(minutes: 2));
    final delay = refreshAt.difference(DateTime.now());
    _tokenRefreshTimer = Timer(
      delay.isNegative ? const Duration(seconds: 1) : delay,
      () => unawaited(_reconnect(forceRefresh: true)),
    );
  }

  Future<String?> _freshAccessToken({bool forceRefresh = false}) async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;
    return accessToken;
  }

  DateTime? _jwtExpiry(String? token) {
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final exp = json['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _notificationPayload(Object? data) {
    final map = _map(data);
    final nested = map['data'] ?? map['notification'];
    if (nested is Map) return _map(nested);
    return map;
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  String _safeError(Object? error) {
    final text = error?.toString() ?? 'unknown';
    return text.replaceAll(RegExp(r'token=[^&\s#]+'), 'token=<redacted>');
  }
}
