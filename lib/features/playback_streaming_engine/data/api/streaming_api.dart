import 'package:dio/dio.dart';

import '../../domain/entities/playback_event.dart';
import '../../domain/entities/playback_status.dart';
import '../dto/history_track_dto.dart';
import '../dto/playback_context_response_dto.dart';
import '../dto/stream_response_dto.dart';
import '../dto/track_playback_bundle_dto.dart';
import '../../../../core/network/api_endpoints.dart';

class StreamingApi {
  StreamingApi(this._dio);

  final Dio _dio;

  // -------------------------------------------------------------------------
  // 5.1  GET /tracks/{trackId}/playback
  // -------------------------------------------------------------------------
  Future<TrackPlaybackBundleDto> getPlaybackBundle(
    String trackId, {
    String? privateToken,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.trackPlayback(trackId),
      queryParameters: privateToken != null
          ? {'privateToken': privateToken}
          : null,
    );
    return TrackPlaybackBundleDto.fromJson(
      _unwrap(response.data),
    );
  }

  // -------------------------------------------------------------------------
  // 5.2  POST /tracks/{trackId}/stream
  // -------------------------------------------------------------------------
  Future<StreamResponseDto> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
  }) async {
    final response = await _dio.post(
      ApiEndpoints.trackStream(trackId),
      data: {'quality': quality},
    );
    return StreamResponseDto.fromJson(
      _unwrap(response.data),
      trackId,
    );
  }

  // -------------------------------------------------------------------------
  // 5.3  PATCH /me/playback/events
  // -------------------------------------------------------------------------
  Future<void> reportPlaybackEvent({
    required String trackId,
    required PlaybackAction action,
    required int positionSeconds,
  }) async {
    await _dio.patch(
      ApiEndpoints.playbackEvents,
      data: {
        'trackId': trackId,
        'action': _actionToString(action),
        'positionSeconds': positionSeconds,
      },
    );
  }

  // -------------------------------------------------------------------------
  // 5.4  POST /playback/context
  // -------------------------------------------------------------------------
  Future<PlaybackContextResponseDto> buildPlaybackQueue({
    required String contextType,
    required String contextId,
    String? startTrackId,
    bool shuffle = false,
    String repeat = 'none',
  }) async {
    final response = await _dio.post(
      ApiEndpoints.playbackContext,
      data: {
        'contextType': contextType,
        'contextId': contextId,
        if (startTrackId != null) 'startTrackId': startTrackId,
        'shuffle': shuffle,
        'repeat': repeat,
      },
    );
    return PlaybackContextResponseDto.fromJson(_unwrap(response.data));
  }

  // -------------------------------------------------------------------------
  // 5.5  GET /me/listening-history
  // -------------------------------------------------------------------------
  Future<List<HistoryTrackDto>> getListeningHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.listeningHistory,
      queryParameters: {'page': page, 'limit': limit},
    );

    final raw = _unwrap(response.data);

    // Response shape: { data: [...], meta: {...} }
    final list = raw['data'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(HistoryTrackDto.fromJson)
        .toList();
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Unwrap optional { data: {...} } envelope the backend may add.
  Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw StateError('Unexpected response shape from streaming API: $raw');
    }
    if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
      return raw['data'] as Map<String, dynamic>;
    }
    return raw;
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
      case PlaybackContextType.playlist:
        return 'playlist';
      case PlaybackContextType.feed:
        return 'feed';
      case PlaybackContextType.profile:
        return 'profile';
      case PlaybackContextType.history:
        return 'history';
    }
  }
}
