import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/realtime_event.dart';
import '../dto/message_dto.dart';
import '../mappers/messaging_mapper.dart';
import 'messaging_socket.dart';

/// Connects to the backend Socket.IO `/conversations` namespace.
///
/// URL form matches the JS frontend the backend team confirmed works:
///   io('https://tunify.duckdns.org/conversations',
///      { transports: ['websocket'], query: { token } });
///
/// Reconnection is delegated entirely to `socket_io_client`'s built-in
/// reconnection — we don't add a parallel manual reconnect (the two used
/// to fight each other and produced rapid connect/disconnect cycles).
class RealMessagingSocket implements MessagingSocket {
  RealMessagingSocket(this._tokenStorage);

  final TokenStorage _tokenStorage;

  static const String _socketUrl = String.fromEnvironment(
    'MESSAGING_WS_URL',
    defaultValue: 'https://tunify.duckdns.org/conversations',
  );

  io.Socket? _socket;
  final _controller = StreamController<RealtimeMessagingEvent>.broadcast();

  bool _connected = false;
  bool _connecting = false;
  bool _disposed = false;

  /// Pending `message:send` calls keyed by client-side tempId.
  ///
  /// We don't block the UI on the server ack — `sendMessage` resolves
  /// immediately with an optimistic DTO and the broadcast `message:received`
  /// later replaces it via `_resolvePendingFrom`. The map stays around so
  /// duplicates can be detected and reconciled if the server does echo.
  final Map<String, _PendingSend> _pending = {};
  int _tempSeq = 0;

  /// Conversation rooms the caller wants to be in. We never drop these on
  /// disconnect — instead they're re-emitted on every `onConnect` so the
  /// caller doesn't need to know about reconnects.
  final Set<String> _activeRooms = <String>{};

  @override
  Stream<RealtimeMessagingEvent> get events => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    if (_disposed) return;
    if (_connected) return;
    if (_connecting) return;
    _connecting = true;
    try {
      final token = await _accessToken();
      if (token == null || token.isEmpty) {
        debugPrint('[MessagingSocket] No access token — skipping connect');
        return;
      }
      _openSocket(token);
    } finally {
      _connecting = false;
    }
  }

  @override
  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connected = false;
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
    _activeRooms.add(conversationId);
    if (!_connected) {
      unawaited(connect());
      return;
    }
    _socket?.emit('conversation:join', {'conversationId': conversationId});
  }

  @override
  Future<void> leaveConversation(String conversationId) async {
    if (conversationId.isEmpty) return;
    _activeRooms.remove(conversationId);
    if (!_connected) return;
    _socket?.emit('conversation:leave', {'conversationId': conversationId});
  }

  @override
  Future<MessageDto> sendMessage(Map<String, dynamic> payload) async {
    if (!_connected) {
      // Try to connect, but don't block forever — if the socket isn't ready
      // we surface an error so the UI can handle it.
      await connect();
    }
    if (!_connected || _socket == null) {
      throw StateError('Messaging socket is not connected.');
    }

    final conversationId = (payload['conversationId'] ?? '').toString();
    if (conversationId.isNotEmpty && !_activeRooms.contains(conversationId)) {
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

    // Resolve optimistically — the chat UI shouldn't have to wait for the
    // server round-trip to render the bubble. The broadcast updates state
    // again via `message:received` if the server echoes it.
    Timer.run(() {
      final pending = _pending[tempId];
      if (pending != null && !pending.completer.isCompleted) {
        pending.completer.complete(_optimisticDtoFromPayload(enriched, ''));
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
    _socket?.dispose();

    debugPrint('[MessagingSocket] connecting to $_socketUrl');
    _socket = io.io(
      _socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .setQuery({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(0x7fffffff) // never give up
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );

    _socket!.onConnect((_) {
      _connected = true;
      debugPrint('[MessagingSocket] connected');
      // Re-join every active room — the backend forgets membership on
      // disconnect, so the client must re-emit on every reconnect.
      for (final room in _activeRooms) {
        _socket?.emit('conversation:join', {'conversationId': room});
      }
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      debugPrint('[MessagingSocket] disconnected');
    });

    _socket!.onConnectError((err) {
      _connected = false;
      debugPrint('[MessagingSocket] connect error: ${_safeError(err)}');
    });

    _socket!.onError((err) {
      debugPrint('[MessagingSocket] socket error: ${_safeError(err)}');
    });

    _socket!.on('authenticated', (_) {
      debugPrint('[MessagingSocket] authenticated');
    });

    _socket!.on('joined', (_) {
      // Server-confirmed join. No state change needed since `_activeRooms`
      // already tracks the desired membership.
    });

    _socket!.on('left', (_) {});

    _socket!.on('message:sent', (data) {
      final m = _safeMap(data);
      final tempId = (m['tempId'] ?? '').toString();
      final serverId = (m['messageId'] ?? m['id'] ?? '').toString();
      if (tempId.isEmpty) return;

      final pending = _pending[tempId];
      if (pending == null) return;
      if (pending.completer.isCompleted) {
        _pending.remove(tempId);
        return;
      }

      // Replace the optimistic DTO with one that has the canonical id.
      pending.completer.complete(
        _optimisticDtoFromPayload(pending.payload, serverId),
      );
      _pending.remove(tempId);
    });

    _socket!.on('message:received', (data) {
      try {
        final m = _safeMap(data);
        final msgJson = m['message'] is Map ? _safeMap(m['message']) : m;
        final convoId = (m['conversationId'] ?? msgJson['conversationId'] ?? '')
            .toString();
        final dto = MessageDto.fromJson(
          msgJson,
          fallbackConversationId: convoId,
        );

        _resolvePendingFrom(dto, m);
        _controller.add(MessageReceivedEvent(MessagingMapper.message(dto)));
      } catch (e) {
        debugPrint('[MessagingSocket] message:received parse error: $e');
      }
    });

    _socket!.on('read:success', (_) {});

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

  void _resolvePendingFrom(MessageDto dto, Map<String, dynamic> envelope) {
    final tempId = envelope['tempId']?.toString();
    if (tempId != null && tempId.isNotEmpty) {
      final pending = _pending.remove(tempId);
      if (pending != null && !pending.completer.isCompleted) {
        pending.completer.complete(dto);
      }
      return;
    }

    // Fallback heuristic — match by content the client just sent.
    _PendingSend? match;
    for (final entry in _pending.entries) {
      final p = entry.value;
      if (p.conversationId != dto.conversationId) continue;
      final sent = p.payload['content'] ?? p.payload['text'];
      if (sent == dto.text) {
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
    Map<String, dynamic> payload,
    String serverId,
  ) {
    final convoId = (payload['conversationId'] ?? '').toString();
    final type = (payload['type'] ?? 'TEXT').toString().toUpperCase();
    final content = payload['content'] as String?;
    final tempId = (payload['tempId'] ?? '').toString();

    return MessageDto.fromJson({
      'id': serverId.isNotEmpty ? serverId : tempId,
      'conversationId': convoId,
      // Marker so `chat_controller` can recognise an optimistic message and
      // tag it as the current user without needing extra plumbing.
      'senderId': '__me__',
      'type': type,
      if (content != null) 'content': content,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'read': true,
      if (payload['trackId'] != null ||
          payload['collectionId'] != null ||
          payload['userId'] != null)
        'attachment': {
          'id': (payload['trackId'] ??
                  payload['collectionId'] ??
                  payload['userId'] ??
                  '')
              .toString(),
          'type': type,
        },
    }, fallbackConversationId: convoId);
  }

  Future<String?> _accessToken() async {
    final access = await _tokenStorage.getAccessToken();
    if (access == null || access.isEmpty) return null;
    return access;
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
