import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
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

  /// Current backend contract (v1.1.0):
  /// GET /tracks/{trackId}/stream
  ///
  /// Older drafts of the contract used POST. We try GET first and only fall
  /// back to POST for compatibility with older deployments.
  Future<StreamResponseDto> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
  }) async {
    try {
      final response = await _dio.get(ApiEndpoints.trackStream(trackId));
      return StreamResponseDto.fromJson(_unwrapMap(response.data), trackId);
    } on DioException catch (error) {
      if (!_isMethodOrRouteMismatch(error)) rethrow;
    }

    final fallbackResponse = await _dio.post(
      ApiEndpoints.trackStream(trackId),
      data: {
        'quality': quality,
      },
    );

    return StreamResponseDto.fromJson(
      _unwrapMap(fallbackResponse.data),
      trackId,
    );
  }

  /// The newest contract no longer exposes /me/playback/events.
  ///
  /// We keep this method for compatibility with the existing provider and
  /// repository layers. If the backend still supports the old endpoint, we use
  /// it. If the backend returns 404/405 because the endpoint was removed in the
  /// new contract, we silently ignore it so playback and history screens keep
  /// working.
  Future<void> reportPlaybackEvent({
    required String trackId,
    required PlaybackAction action,
    required int positionSeconds,
  }) async {
    try {
      await _dio.patch(
        ApiEndpoints.playbackEvents,
        data: {
          'trackId': trackId,
          'action': _actionToString(action),
          'positionSeconds': positionSeconds,
        },
      );
    } on DioException catch (error) {
      if (_isMethodOrRouteMismatch(error)) {
        return;
      }
      rethrow;
    }
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