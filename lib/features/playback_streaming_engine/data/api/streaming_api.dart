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

  /// Latest backend contract:
  /// GET /tracks/{trackId}/stream
  ///
  /// This endpoint returns the signed streaming URL and also records
  /// the play event in play_history on the backend.
  Future<StreamResponseDto> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
  }) async {
    final response = await _dio.get(
      ApiEndpoints.trackStream(trackId),
      queryParameters: quality == 'auto' ? null : {'quality': quality},
    );

    return StreamResponseDto.fromJson(_unwrapMap(response.data), trackId);
  }

  /// The latest backend doc you sent does not include the old
  /// "progress/pause/play analytics patch endpoint" in this version.
  ///
  /// We keep this method as a no-op so the current repository/usecase/provider
  /// layers continue compiling without forcing you to refactor everything now.
  ///
  /// Listening history still works because it is recorded through:
  /// GET /tracks/{trackId}/stream
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

    return PlaybackContextResponseDto.fromJson(_unwrapMap(response.data));
  }

  Future<List<HistoryTrackDto>> getListeningHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.listeningHistory,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final raw = response.data;
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