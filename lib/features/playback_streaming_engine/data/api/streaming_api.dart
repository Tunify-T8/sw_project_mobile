import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/offline_play_record.dart';
import '../../domain/entities/playback_event.dart';
import '../../domain/entities/playback_status.dart';
import '../dto/history_track_dto.dart';
import '../dto/playback_context_response_dto.dart';
import '../dto/stream_response_dto.dart';
import '../dto/track_playback_bundle_dto.dart';

class StreamingApi {
  StreamingApi(this._dio);

  final Dio _dio;

  Future<TrackPlaybackBundleDto> getPlaybackBundle(
    String trackId, {
    String? privateToken,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.trackPlayback(trackId),
      queryParameters:
          privateToken != null ? {'privateToken': privateToken} : null,
    );

    return TrackPlaybackBundleDto.fromJson(_unwrapMap(response.data));
  }

  /// Current backend contract:
  /// GET /tracks/{trackId}/stream
  ///
  /// For private tracks the backend requires the privateToken query param,
  /// otherwise it responds with 403 `private_no_token`.
  /// Older drafts used POST, so we still keep the GET -> POST fallback.
  Future<StreamResponseDto> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
    String? privateToken,
  }) async {
    final query = <String, dynamic>{};
    if (privateToken != null && privateToken.trim().isNotEmpty) {
      query['privateToken'] = privateToken.trim();
    }

    try {
      final response = await _dio.get(
        ApiEndpoints.trackStream(trackId),
        queryParameters: query.isEmpty ? null : query,
      );
      return StreamResponseDto.fromJson(_unwrapMap(response.data), trackId);
    } on DioException catch (error) {
      if (!_isMethodOrRouteMismatch(error)) rethrow;
    }

    final fallbackResponse = await _dio.post(
      ApiEndpoints.trackStream(trackId),
      queryParameters: query.isEmpty ? null : query,
      data: {
        'quality': quality,
        if (privateToken != null && privateToken.trim().isNotEmpty)
          'privateToken': privateToken.trim(),
      },
    );

    return StreamResponseDto.fromJson(
      _unwrapMap(fallbackResponse.data),
      trackId,
    );
  }

  /// No-op on purpose.
  ///
  /// Your current backend no longer supports `/me/playback/events`, and keeping
  /// the network call here only creates noisy 404 logs while adding no value to
  /// playback.
  Future<void> reportPlaybackEvent({
    required String trackId,
    required PlaybackAction action,
    required int positionSeconds,
  }) async {
    return;
  }

  Future<PlaybackContextResponseDto> buildPlaybackQueue({
    required String contextType,
    required String contextId,
    String? startTrackId,
    bool shuffle = false,
    String repeat = 'none',
  }) async {
    final payload = {
      'contextType': contextType,
      'contextId': contextId,
      if (startTrackId != null) 'startTrackId': startTrackId,
      'shuffle': shuffle,
      'repeat': repeat,
    };

    try {
      final response = await _dio.post(
        ApiEndpoints.playbackContext,
        data: payload,
      );

      return PlaybackContextResponseDto.fromJson(_unwrapMap(response.data));
    } on DioException catch (error) {
      if (!_isMethodOrRouteMismatch(error)) rethrow;
    }

    final fallbackResponse = await _dio.post(
      ApiEndpoints.legacyPlaybackContext,
      data: payload,
    );

    return PlaybackContextResponseDto.fromJson(
      _unwrapMap(fallbackResponse.data),
    );
  }

  Future<List<HistoryTrackDto>> getListeningHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = {
      'page': page,
      'limit': limit,
    };

    try {
      final response = await _dio.get(
        ApiEndpoints.listeningHistory,
        queryParameters: queryParameters,
      );

      return _parseListeningHistory(response.data);
    } on DioException catch (error) {
      if (!_isMethodOrRouteMismatch(error)) rethrow;
    }

    final fallbackResponse = await _dio.get(
      ApiEndpoints.legacyListeningHistory,
      queryParameters: queryParameters,
    );

    return _parseListeningHistory(fallbackResponse.data);
  }

  /// DELETE /tracks/me/listening-history
  ///
  /// Clears the user's listening history on the backend, with fallback to the
  /// older `/me/listening-history` contract while the deployed server catches
  /// up.
  Future<void> clearListeningHistory() async {
    try {
      await _dio.delete(ApiEndpoints.clearListeningHistory);
      return;
    } on DioException catch (error) {
      if (!_isMethodOrRouteMismatch(error)) rethrow;
    }

    try {
      await _dio.delete(ApiEndpoints.legacyClearListeningHistory);
    } on DioException catch (error) {
      // If neither contract exists yet, silently succeed because the provider
      // still clears locally and guards against stale backend rows.
      if (_isMethodOrRouteMismatch(error)) return;
      rethrow;
    }
  }

  /// POST /tracks/{trackId}/played
  ///
  /// Called once when the user reaches 90 % of a track naturally.
  /// The server applies a 30-second dedup window, so 409 responses are safe
  /// to ignore.
  Future<void> reportTrackCompleted(String trackId) async {
    try {
      await _dio.post(ApiEndpoints.trackPlayed(trackId));
    } on DioException catch (e) {
      // 409 = already recorded within the dedup window — not an error.
      if (e.response?.statusCode == 409) return;
      rethrow;
    }
  }

  /// POST /tracks/plays/batch
  ///
  /// Sends all plays that were recorded while the device was offline.
  /// [plays] must not be empty.
  Future<void> reportBatchOfflinePlays(List<OfflinePlayRecord> plays) async {
    await _dio.post(
      ApiEndpoints.batchPlays,
      data: {
        'plays': plays.map((p) => p.toJson()).toList(),
      },
    );
  }

  List<HistoryTrackDto> _parseListeningHistory(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw StateError('Unexpected listening history response: $raw');
    }

    final list = raw['data'] as List<dynamic>? ?? const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(HistoryTrackDto.fromJson)
        .toList();
  }

  Map<String, dynamic> _unwrapMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw StateError('Unexpected response shape from streaming API: $raw');
    }

    if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
      return raw['data'] as Map<String, dynamic>;
    }

    return raw;
  }

  bool _isMethodOrRouteMismatch(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 404 || statusCode == 405;
  }

  static String contextTypeToString(PlaybackContextType type) {
    switch (type) {
      case PlaybackContextType.track:
        return 'track';
      case PlaybackContextType.feed:
        return 'feed';
      case PlaybackContextType.playlist:
        return 'playlist';
      case PlaybackContextType.profile:
        return 'profile';
      case PlaybackContextType.history:
        return 'history';
    }
  }
}
