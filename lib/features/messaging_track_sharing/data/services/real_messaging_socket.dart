import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/realtime_event.dart';
import '../dto/message_dto.dart';
import '../mappers/messaging_mapper.dart';
import 'messaging_socket.dart';

/// Connects to the backend Socket.IO `/conversations` namespace.
///
/// Backend: @WebSocketGateway({ namespace: '/conversations' }), port 3001
/// Auth:    handshake.query.token <- JWT access token
/// Events:  authenticated | joined | left | message:sent | message:received
///          | message:read | read:success | typing:active | typing:inactive
///          | error
class RealMessagingSocket implements MessagingSocket {
  RealMessagingSocket(this._tokenStorage);

  final TokenStorage _tokenStorage;

  io.Socket? _socket;
  final _controller = StreamController<RealtimeMessagingEvent>.broadcast();

  bool _connected = false;
  bool _connecting = false;
  bool _disposed = false;
  int _reconnectAttempt = 0;

  Timer? _manualReconnectTimer;
  Timer? _tokenRefreshTimer;

  /// Pending `message:send` calls keyed by client-side tempId. The backend
  /// acks with `message:sent` (carries the server-assigned id) and then
  /// broadcasts `message:received` which the room listens for.
  final Map<String, _PendingSend> _pending = {};
  int _tempSeq = 0;

  /// Conversation rooms we tried to join while the socket was still
  /// connecting — replayed on `onConnect`.
  final Set<String> _pendingJoins = <String>{};
  final Set<String> _joinedRooms = <String>{};

  /// Returns a base URL like `https://tunify.duckdns.org:443` — Socket.IO v2+
  /// resolves to port 0 when the port is omitted so we pin it explicitly.
  static String get _wsBaseUrl {
    final uri = Uri.parse(ApiEndpoints.baseUrl);
    final port = (uri.hasPort && uri.port != 0)
        ? uri.port
        : (uri.scheme == 'https' ? 443 : 80);
    return '${uri.scheme}://${uri.host}:$port';
  }

  @override
  Stream<RealtimeMessagingEvent> get events => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    if (_connected || _connecting || _disposed) return;
    _connecting = true;
    try {
      final token = await _freshAccessToken();
      if (token == null || token.isEmpty) {
        debugPrint('[MessagingSocket] No access token — skipping connect');
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
    _joinedRooms.clear();
  }

  void dispose() {
    _disposed = true;
    disconnect();
    for (final pending in _pending.values) {
      if (!pending.completer.isCompleted) {
        pending.completer.completeError(
          StateError('MessagingSocket disposed before ack.'),
        );
      }
    }
    _pending.clear();
    _controller.close();
  }

  @override
  Future<void> joinConversation(String conversationId) async {
    if (conversationId.isEmpty) return;
    if (!_connected) {
      _pendingJoins.add(conversationId);
      unawaited(connect());
      return;
    }
    if (_joinedRooms.contains(conversationId)) return;
    _joinedRooms.add(conversationId);
    _socket?.emit('conversation:join', {'conversationId': conversationId});
  }

  @override
  Future<void> leaveConversation(String conversationId) async {
    if (conversationId.isEmpty) return;
    _joinedRooms.remove(conversationId);
    _pendingJoins.remove(conversationId);
    if (!_connected) return;
    _socket?.emit('conversation:leave', {'conversationId': conversationId});
  }

  @override
  Future<MessageDto> sendMessage(Map<String, dynamic> payload) async {
    if (!_connected) {
      await connect();
    }
    if (!_connected || _socket == null) {
      throw StateError('Messaging socket is not connected.');
    }

    final conversationId = (payload['conversationId'] ?? '').toString();
    if (conversationId.isNotEmpty && !_joinedRooms.contains(conversationId)) {
      await joinConversation(conversationId);
    }

    final tempId = 'tmp_${DateTime.now().microsecondsSinceEpoch}_${_tempSeq++}';
    final enriched = <String, dynamic>{...payload, 'tempId': tempId};

    final completer = Completer<MessageDto>();
    _pending[tempId] = _PendingSend(
      completer: completer,
      conversationId: conversationId,
      payload: enriched,
    );

    _socket!.emit('message:send', enriched);

    // Safety net — if the server doesn't ack within 20s, fail the send so
    // the UI can surface an error instead of spinning forever.
    Timer(const Duration(seconds: 20), () {
      final pending = _pending.remove(tempId);
      if (pending != null && !pending.completer.isCompleted) {
        pending.completer.completeError(
          TimeoutException('message:send timed out'),
        );
      }
    });

    return completer.future;
  }

  @override
  Future<void> markMessageRead({
    required String conversationId,
    required String messageId,
  }) async {
    if (!_connected) await connect();
    if (!_connected) return;
    _socket?.emit('message:markRead', {
      'conversationId': conversationId,
      'messageId': messageId,
    });
  }

  @override
  void startTyping(String conversationId) {
    if (!_connected) return;
    _socket?.emit('typing:start', {'conversationId': conversationId});
  }

  @override
  void stopTyping(String conversationId) {
    if (!_connected) return;
    _socket?.emit('typing:stop', {'conversationId': conversationId});
  }

  // ── internals ────────────────────────────────────────────────────────────

  void _openSocket(String token) {
    _manualReconnectTimer?.cancel();
    _socket?.dispose();

    _socket = io.io(
      '$_wsBaseUrl/conversations',
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
      debugPrint('[MessagingSocket] connected');
      _replayPendingJoins();
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      _joinedRooms.clear();
      debugPrint('[MessagingSocket] disconnected');
      _scheduleManualReconnect();
    });

    _socket!.onConnectError((err) {
      _connected = false;
      debugPrint('[MessagingSocket] connect error: ${_safeError(err)}');
      _scheduleManualReconnect();
    });

    _socket!.on('authenticated', (_) {
      debugPrint('[MessagingSocket] authenticated');
    });

    _socket!.on('joined', (data) {
      final m = _safeMap(data);
      final id = (m['conversationId'] ?? '').toString();
      if (id.isNotEmpty) _joinedRooms.add(id);
    });

    _socket!.on('left', (data) {
      final m = _safeMap(data);
      final id = (m['conversationId'] ?? '').toString();
      _joinedRooms.remove(id);
    });

    _socket!.on('message:sent', (data) {
      final m = _safeMap(data);
      final tempId = (m['tempId'] ?? '').toString();
      final serverId = (m['messageId'] ?? m['id'] ?? '').toString();
      if (tempId.isEmpty) return;

      final pending = _pending[tempId];
      if (pending == null) return;

      // If we already got message:received before the ack (rare but possible),
      // the completer is done — nothing to do.
      if (pending.completer.isCompleted) {
        _pending.remove(tempId);
        return;
      }

      // Otherwise build an optimistic DTO from the payload + server id so
      // the repo has something to return immediately. The canonical version
      // will still arrive via message:received and update state.
      final dto = _optimisticDtoFromPayload(pending.payload, serverId);
      pending.completer.complete(dto);
      _pending.remove(tempId);
    });

    _socket!.on('message:received', (data) {
      try {
        final m = _safeMap(data);
        final msgJson = m['message'] is Map
            ? _safeMap(m['message'])
            : m;
        final convoId = (m['conversationId'] ??
                msgJson['conversationId'] ??
                '')
            .toString();
        final dto = MessageDto.fromJson(
          msgJson,
          fallbackConversationId: convoId,
        );

        // Resolve any still-pending send with this server id (or tempId).
        _resolvePendingFrom(dto, m);

        _controller.add(MessageReceivedEvent(MessagingMapper.message(dto)));
      } catch (e) {
        debugPrint('[MessagingSocket] message:received parse error: $e');
      }
    });

    _socket!.on('read:success', (_) {
      // Silent ack — no UI update needed; the broadcast will follow.
    });

    _socket!.on('message:read', (data) {
      final m = _safeMap(data);
      final convoId = (m['conversationId'] ?? '').toString();
      final messageId = (m['messageId'] ?? '') as String?;
      final readerId = (m['readerId'] ?? m['userId'] ?? '').toString();
      if (convoId.isEmpty) return;
      _controller.add(
        MessageReadEvent(
          conversationId: convoId,
          readerUserId: readerId,
          messageId:
              (messageId == null || messageId.isEmpty) ? null : messageId,
        ),
      );
    });

    _socket!.on('typing:active', (data) {
      final m = _safeMap(data);
      final convoId = (m['conversationId'] ?? '').toString();
      final userId = (m['userId'] ?? '').toString();
      if (convoId.isEmpty || userId.isEmpty) return;
      _controller.add(TypingEvent(
        conversationId: convoId,
        userId: userId,
        isTyping: true,
      ));
    });

    _socket!.on('typing:inactive', (data) {
      final m = _safeMap(data);
      final convoId = (m['conversationId'] ?? '').toString();
      final userId = (m['userId'] ?? '').toString();
      if (convoId.isEmpty || userId.isEmpty) return;
      _controller.add(TypingEvent(
        conversationId: convoId,
        userId: userId,
        isTyping: false,
      ));
    });

    _socket!.on('error', (data) {
      final m = _safeMap(data);
      debugPrint('[MessagingSocket] server error: ${m['message']}');
    });

    _socket!.connect();
  }

  void _replayPendingJoins() {
    if (_pendingJoins.isEmpty) return;
    final joins = List<String>.from(_pendingJoins);
    _pendingJoins.clear();
    for (final id in joins) {
      _joinedRooms.add(id);
      _socket?.emit('conversation:join', {'conversationId': id});
    }
  }

  void _resolvePendingFrom(MessageDto dto, Map<String, dynamic> envelope) {
    final tempId = envelope['tempId']?.toString();
    if (tempId != null && tempId.isNotEmpty) {
      final pending = _pending.remove(tempId);
      if (pending != null && !pending.completer.isCompleted) {
        pending.completer.complete(dto);
      }
      return;
    }

    // Heuristic fallback — match by (conversation, sender, text, creation within 5s).
    _PendingSend? match;
    for (final entry in _pending.entries) {
      final p = entry.value;
      if (p.conversationId != dto.conversationId) continue;
      if ((p.payload['content'] ?? p.payload['text']) == dto.text) {
        match = p;
        break;
      }
    }
    if (match != null && !match.completer.isCompleted) {
      _pending.remove(match.payload['tempId']);
      match.completer.complete(dto);
    }
  }

  MessageDto _optimisticDtoFromPayload(
      Map<String, dynamic> payload, String serverId) {
    final convoId = (payload['conversationId'] ?? '').toString();
    final type = (payload['type'] ?? 'TEXT').toString().toUpperCase();
    final content = payload['content'] as String?;

    return MessageDto.fromJson(
      {
        'id': serverId.isEmpty ? payload['tempId'] : serverId,
        'conversationId': convoId,
        'senderId': '',
        'type': type,
        if (content != null) 'content': content,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'read': true,
        if (payload['trackId'] != null || payload['collectionId'] != null ||
            payload['userId'] != null)
          'attachment': {
            'id': (payload['trackId'] ??
                    payload['collectionId'] ??
                    payload['userId'] ??
                    '')
                .toString(),
            'type': type,
          },
      },
      fallbackConversationId: convoId,
    );
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

      // Re-queue active rooms so they get rejoined after reconnect.
      _pendingJoins.addAll(_joinedRooms);
      _joinedRooms.clear();

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
    final access = await _tokenStorage.getAccessToken();
    if (!forceRefresh && !_isExpiringSoon(access)) return access;

    final refresh = await _tokenStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return access;

    try {
      final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refresh},
      );
      final body = _safeMap(response.data);
      final nested = body['data'];
      final data = nested is Map ? _safeMap(nested) : body;

      final newAccess = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (newAccess == null || newRefresh == null) return access;

      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      return newAccess;
    } on DioException catch (e) {
      debugPrint(
          '[MessagingSocket] token refresh failed: ${_safeDioError(e)}');
      return _isExpired(access) ? null : access;
    } catch (e) {
      debugPrint('[MessagingSocket] token refresh failed: ${e.runtimeType}');
      return _isExpired(access) ? null : access;
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

  Map<String, dynamic> _safeMap(Object? value) {
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

  String _safeDioError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    final message = data is Map && data['message'] != null
        ? data['message'].toString()
        : error.message;
    return 'status=${status ?? 'none'}, message=$message';
  }
}

class _PendingSend {
  final Completer<MessageDto> completer;
  final String conversationId;
  final Map<String, dynamic> payload;

  _PendingSend({
    required this.completer,
    required this.conversationId,
    required this.payload,
  });
}
