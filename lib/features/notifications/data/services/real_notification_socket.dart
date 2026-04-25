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
/// Same URL form as the JS frontend the backend team confirmed works:
///   io('https://tunify.duckdns.org/notifications', { transports: ['websocket'] })
///
/// Reconnection is handled entirely by `socket_io_client`'s built-in logic
/// (`enableReconnection`). We don't add a parallel manual reconnect — the
/// two used to fight each other and produced rapid connect/disconnect cycles.
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
      final token = await _accessToken();
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
    _socket?.dispose();

    debugPrint('[NotificationSocket] connecting to $_socketUrl');

    _socket = io.io(
      _socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .setQuery({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(0x7fffffff)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          .disableAutoConnect()
          .enableForceNew()
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
      debugPrint('[NotificationSocket] connect error: ${_safeError(err)}');
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

  Future<void> _refreshTokenAndReopen() async {
    if (_disposed) return;
    final token = await _accessToken();
    if (token == null || token.isEmpty) return;
    _openSocket(token);
    _scheduleTokenRefresh(token);
  }

  void _scheduleTokenRefresh(String token) {
    _tokenRefreshTimer?.cancel();
    final expiresAt = _jwtExpiry(token);
    if (expiresAt == null) return;

    final refreshAt = expiresAt.subtract(const Duration(minutes: 2));
    final delay = refreshAt.difference(DateTime.now());
    _tokenRefreshTimer = Timer(
      delay.isNegative ? const Duration(seconds: 1) : delay,
      () => unawaited(_refreshTokenAndReopen()),
    );
  }

  Future<String?> _accessToken() async {
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
