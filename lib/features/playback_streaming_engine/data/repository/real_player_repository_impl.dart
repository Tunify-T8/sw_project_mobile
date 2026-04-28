import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/storage/safe_secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/entities/history_track.dart';
import '../../domain/entities/offline_play_record.dart';
import '../../domain/entities/playback_context_request.dart';
import '../../domain/entities/playback_event.dart';
import '../../domain/entities/playback_queue.dart';
import '../../domain/entities/playback_status.dart';
import '../../domain/entities/stream_url.dart';
import '../../domain/entities/track_playback_bundle.dart';
import '../../domain/repositories/player_repository.dart';
import '../api/streaming_api.dart';
import '../mapper/playback_mapper.dart';

class RealPlayerRepository implements PlayerRepository {
  RealPlayerRepository(this._api);

  final StreamingApi _api;

  final List<PlaybackEvent> _pendingEvents = [];
  Timer? _retryTimer;
  bool _isFlushingPending = false;
  bool _hasLoadedPendingEvents = false;

  // ── Offline plays queue ──────────────────────────────────────────────────
  final List<OfflinePlayRecord> _offlinePlays = [];
  bool _hasLoadedOfflinePlays = false;
  bool _isFlushingOfflinePlays = false;

  @override
  Future<TrackPlaybackBundle> getPlaybackBundle(
    String trackId, {
    String? privateToken,
  }) async {
    final dto = await _api.getPlaybackBundle(
      trackId,
      privateToken: privateToken,
    );
    return dto.toEntity();
  }

  @override
  Future<StreamUrl> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
    String? privateToken,
  }) async {
    final dto = await _api.requestStreamUrl(trackId, quality: quality, privateToken: privateToken);
    return dto.toEntity();
  }

  @override
  Future<void> reportPlaybackEvent(PlaybackEvent event) async {
    await _ensurePendingLoaded();
    await _flushPendingEventsIfPossible();

    try {
      await _sendEvent(event);
    } catch (error) {
      if (_shouldQueueForRetry(error)) {
        await _enqueuePendingEvent(event);
        _ensureRetryTimer();
        return;
      }
      rethrow;
    }
  }

  @override
  Future<PlaybackQueue> buildPlaybackQueue(
    PlaybackContextRequest request,
  ) async {
    final dto = await _api.buildPlaybackQueue(
      contextType: StreamingApi.contextTypeToString(request.contextType),
      contextId: request.contextId,
      startTrackId: request.startTrackId,
      shuffle: request.shuffle,
      repeat: _repeatToString(request.repeat),
    );
    return dto.toEntity();
  }

  @override
  Future<List<HistoryTrack>> getListeningHistory({
    int page = 1,
    int limit = 20,
  }) async {
    await _ensurePendingLoaded();
    await _flushPendingEventsIfPossible();

    // Flush offline batch plays before pulling fresh history so the server
    // has the most up-to-date play data when it responds.
    await _ensureOfflinePlaysLoaded();
    await _flushOfflinePlaysIfPossible();

    final dtos = await _api.getListeningHistory(page: page, limit: limit);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> clearListeningHistory() async {
    await _api.clearListeningHistory();
  }

  // ── reportTrackCompleted ─────────────────────────────────────────────────

  @override
  Future<void> reportTrackCompleted(String trackId) async {
    await _api.reportTrackCompleted(trackId);
  }

  // ── Offline plays queue ──────────────────────────────────────────────────

  @override
  Future<void> addOfflinePlay(String trackId) async {
    await _ensureOfflinePlaysLoaded();

    // Server-side dedup uses a 30-second window; mirror that locally.
    final isDuplicate = _offlinePlays.any(
      (r) =>
          r.trackId == trackId &&
          DateTime.now().difference(r.playedAt).inSeconds < 30,
    );
    if (isDuplicate) return;

    _offlinePlays.add(OfflinePlayRecord(
      trackId: trackId,
      playedAt: DateTime.now(),
    ));
    await _persistOfflinePlays();
  }

  @override
  Future<void> markOfflinePlayCompleted(String trackId) async {
    await _ensureOfflinePlaysLoaded();

    final index = _offlinePlays.lastIndexWhere((r) => r.trackId == trackId);
    if (index == -1) return;

    _offlinePlays[index] = _offlinePlays[index].markCompleted();
    await _persistOfflinePlays();
  }

  Future<void> reportBatchOfflinePlays(List<OfflinePlayRecord> plays) async {
    await _api.reportBatchOfflinePlays(plays);
  }

  Future<void> _ensureOfflinePlaysLoaded() async {
    if (_hasLoadedOfflinePlays) return;
    _hasLoadedOfflinePlays = true;

    final raw = await SafeSecureStorage.read(StorageKeys.pendingOfflinePlays);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _offlinePlays
        ..clear()
        ..addAll(
          decoded
              .whereType<Map<String, dynamic>>()
              .map(OfflinePlayRecord.fromJson),
        );
    } catch (_) {
      await SafeSecureStorage.delete(StorageKeys.pendingOfflinePlays);
    }
  }

  Future<void> _flushOfflinePlaysIfPossible() async {
    if (_offlinePlays.isEmpty || _isFlushingOfflinePlays) return;
    _isFlushingOfflinePlays = true;

    try {
      await _api.reportBatchOfflinePlays(List.unmodifiable(_offlinePlays));
      _offlinePlays.clear();
      await _persistOfflinePlays();
    } catch (error) {
      if (_shouldQueueForRetry(error)) {
        // Keep the records; they will be retried on the next online trigger.
        return;
      }
      // Non-retryable error (e.g. 400 bad request) — discard to avoid loops.
      _offlinePlays.clear();
      await _persistOfflinePlays();
    } finally {
      _isFlushingOfflinePlays = false;
    }
  }

  Future<void> _persistOfflinePlays() async {
    if (_offlinePlays.isEmpty) {
      await SafeSecureStorage.delete(StorageKeys.pendingOfflinePlays);
      return;
    }

    await SafeSecureStorage.write(
      key: StorageKeys.pendingOfflinePlays,
      value: jsonEncode(_offlinePlays.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> _sendEvent(PlaybackEvent event) {
    return _api.reportPlaybackEvent(
      trackId: event.trackId,
      action: event.action,
      positionSeconds: event.positionSeconds,
    );
  }

  Future<void> _ensurePendingLoaded() async {
    if (_hasLoadedPendingEvents) return;

    final raw = await SafeSecureStorage.read(StorageKeys.pendingPlaybackEvents);
    _hasLoadedPendingEvents = true;

    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _pendingEvents
        ..clear()
        ..addAll(
          decoded.whereType<Map<String, dynamic>>().map(_eventFromJson),
        );
    } catch (_) {
      await SafeSecureStorage.delete(StorageKeys.pendingPlaybackEvents);
    }
  }

  Future<void> _flushPendingEventsIfPossible() async {
    if (_pendingEvents.isEmpty || _isFlushingPending) return;

    _isFlushingPending = true;

    try {
      while (_pendingEvents.isNotEmpty) {
        final event = _pendingEvents.first;

        try {
          await _sendEvent(event);
          _pendingEvents.removeAt(0);
          await _persistPendingEvents();
        } catch (error) {
          if (_shouldQueueForRetry(error)) {
            _ensureRetryTimer();
            break;
          }

          _pendingEvents.removeAt(0);
          await _persistPendingEvents();
        }
      }
    } finally {
      _isFlushingPending = false;

      if (_pendingEvents.isEmpty) {
        _retryTimer?.cancel();
        _retryTimer = null;
      } else {
        _ensureRetryTimer();
      }
    }
  }

  Future<void> _enqueuePendingEvent(PlaybackEvent event) async {
    if (event.action == PlaybackAction.play) {
      final isDuplicatePlay = _pendingEvents.any(
        (pending) =>
            pending.trackId == event.trackId &&
            pending.action == PlaybackAction.play &&
            pending.positionSeconds == event.positionSeconds,
      );

      if (!isDuplicatePlay) {
        _pendingEvents.add(event);
        await _persistPendingEvents();
      }
      return;
    }

    _pendingEvents.removeWhere(
      (pending) =>
          pending.trackId == event.trackId &&
          pending.action != PlaybackAction.play,
    );
    _pendingEvents.add(event);
    await _persistPendingEvents();
  }

  Future<void> _persistPendingEvents() async {
    if (_pendingEvents.isEmpty) {
      await SafeSecureStorage.delete(StorageKeys.pendingPlaybackEvents);
      return;
    }

    final payload = jsonEncode(_pendingEvents.map(_eventToJson).toList());
    await SafeSecureStorage.write(
      key: StorageKeys.pendingPlaybackEvents,
      value: payload,
    );
  }

  void _ensureRetryTimer() {
    _retryTimer ??= Timer.periodic(const Duration(seconds: 8), (_) {
      if (_isFlushingPending || _pendingEvents.isEmpty) return;
      unawaited(_flushPendingEventsIfPossible());
    });
  }

  bool _shouldQueueForRetry(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
          return true;
        case DioExceptionType.cancel:
        case DioExceptionType.badCertificate:
        case DioExceptionType.badResponse:
          return false;
      }
    }

    return false;
  }

  Map<String, dynamic> _eventToJson(PlaybackEvent event) {
    return {
      'trackId': event.trackId,
      'action': _actionToString(event.action),
      'positionSeconds': event.positionSeconds,
    };
  }

  PlaybackEvent _eventFromJson(Map<String, dynamic> json) {
    return PlaybackEvent(
      trackId: json['trackId'] as String? ?? '',
      action: _actionFromString(json['action'] as String? ?? 'progress'),
      positionSeconds: json['positionSeconds'] as int? ?? 0,
    );
  }

  static PlaybackAction _actionFromString(String value) {
    switch (value) {
      case 'play':
        return PlaybackAction.play;
      case 'pause':
        return PlaybackAction.pause;
      case 'progress':
      default:
        return PlaybackAction.progress;
    }
  }

  static String _actionToString(PlaybackAction action) {
    switch (action) {
      case PlaybackAction.play:
        return 'play';
      case PlaybackAction.progress:
        return 'progress';
      case PlaybackAction.pause:
        return 'pause';
    }
  }

  static String _repeatToString(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return 'none';
      case RepeatMode.one:
        return 'one';
      case RepeatMode.all:
        return 'all';
    }
  }
}
