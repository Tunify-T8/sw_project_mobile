import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
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
/// Auth:    socket.handshake.query.token <- JWT access token
/// Event:   'notification' <- server emits the notification payload
class RealNotificationSocket implements NotificationSocket {
  RealNotificationSocket(this._tokenStorage);

  final TokenStorage _tokenStorage;

  io.Socket? _socket;
  final _controller = StreamController<NotificationEntity>.broadcast();
  bool _connected = false;
  bool _connecting = false;
  bool _disposed = false;
  int _reconnectAttempt = 0;
  Timer? _manualReconnectTimer;
  Timer? _tokenRefreshTimer;

  /// Returns e.g. "https://tunify.duckdns.org" with an explicit port so that
  /// socket_io_client v2 does not resolve to port 0.
  static String get _wsBaseUrl {
    final uri = Uri.parse(ApiEndpoints.baseUrl);
    final port = uri.hasPort
        ? uri.port
        : (uri.scheme == 'https' ? 443 : 80);
    return '${uri.scheme}://${uri.host}:$port';
  }

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
        debugPrint('[NotificationSocket] No access token - skipping connect');
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

    // URL  : https://host:443/notifications  — Socket.IO namespace
    // Path : /socket.io                      — Engine.IO handshake path (NestJS default)
    //
    // Port must be explicit (443 for https) — socket_io_client v2 resolves to
    // port 0 when the port is omitted from the URL.
    //
    // Transports start with polling so Engine.IO can complete its HTTP
    // handshake first; it then upgrades to websocket automatically.
    _socket = io.io(
      '$_wsBaseUrl/notifications',
      io.OptionBuilder()
          .setTransports(['polling', 'websocket'])
          .setPath('/socket.io')
          .enableReconnection()
          .setReconnectionAttempts(20)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          .disableAutoConnect()
          .setQuery({'token': token})
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

    _socket!.on('notification', (data) {
      try {
        final map = _notificationPayload(data);
        final dto = NotificationDto.fromJson(map);
        final entity = NotificationMapper.notification(dto);
        _controller.add(entity);
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
    if (!forceRefresh && !_isExpiringSoon(accessToken)) {
      return accessToken;
    }

    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return accessToken;

    try {
      final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final body = _map(response.data);
      final nested = body['data'];
      final data = nested is Map ? _map(nested) : body;
      final newAccessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;
      if (newAccessToken == null || newRefreshToken == null) {
        return accessToken;
      }

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      return newAccessToken;
    } on DioException catch (e) {
      debugPrint(
        '[NotificationSocket] token refresh failed: ${_safeDioError(e)}',
      );
      return _isExpired(accessToken) ? null : accessToken;
    } catch (e) {
      debugPrint('[NotificationSocket] token refresh failed: ${e.runtimeType}');
      return _isExpired(accessToken) ? null : accessToken;
    }
  }

  bool _isExpiringSoon(String? token) {
    final expiresAt = _jwtExpiry(token);
    if (expiresAt == null) return token == null || token.isEmpty;
    return expiresAt.difference(DateTime.now()) < const Duration(minutes: 2);
  }

  bool _isExpired(String? token) {
    final expiresAt = _jwtExpiry(token);
    if (expiresAt == null) return token == null || token.isEmpty;
    return !expiresAt.isAfter(DateTime.now());
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
    throw StateError('Expected map payload');
  }

  String _safeError(Object? error) {
    final text = error?.toString() ?? 'unknown';
    return text.replaceAll(RegExp(r'token=[^&\s#]+'), 'token=<redacted>');
  }

  String _safeDioError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    final message = data is Map && data['message'] != null
        ? data['message'].toString()
        : error.message;
    return 'status=${status ?? 'none'}, message=$message';
  }
}
