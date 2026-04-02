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

  /// Current backend contract:
  /// GET /tracks/{trackId}/stream
  ///
  /// Older drafts used POST, so we still keep the GET -> POST fallback.
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

  /// Also a no-op for now.
  ///
  /// The backend deployment you're using does not expose a clear-history route.
  /// We therefore keep clear history local in the app until the backend adds a
  /// supported endpoint.
  Future<void> clearListeningHistory() async {
    return;
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
