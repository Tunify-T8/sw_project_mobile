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
  //get the track that is playing, and its metadata, playability info (whether the track is playable, blocked, or has some restrictions (e.g. preview only). It may also include a reason for blocking if applicable.), and preview info
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
    return TrackPlaybackBundleDto.fromJson(_unwrap(response.data));
  }

  // -------------------------------------------------------------------------
  // 5.2  POST /tracks/{trackId}/stream
  // -------------------------------------------------------------------------
  // what does it do? It requests a stream URL for the track, which the client can then use to play the audio. The response includes the stream URL and its expiration time, and may also include a preview URL if the track is not fully playable.
  // why is it a POST request? Because it may involve some backend processing to generate a temporary stream URL, and it may also take into account the client's context (e.g. device type, network conditions) to determine the best quality to serve.
  Future<StreamResponseDto> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
  }) async {
    final response = await _dio.post(
      ApiEndpoints.trackStream(trackId),
      data: {'quality': quality},
    );
    return StreamResponseDto.fromJson(_unwrap(response.data), trackId);
  }

  // -------------------------------------------------------------------------
  // 5.3  PATCH /me/playback/events
  // -------------------------------------------------------------------------
  // it reports playback events (play, pause, progress) to the backend for analytics and history tracking purposes. The client sends the track ID, the action (play, pause, or progress), and the current position in seconds. This allows the backend to keep track of how users are interacting with tracks, which can inform recommendations, popularity metrics, and listening history.
  Future<void> reportPlaybackEvent({
    required String trackId,
    required PlaybackAction action,
    required int positionSeconds, // current position in seconds
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
  // it builds a playback queue based on a given context (e.g. a playlist, an artist's profile, the user's feed). The client specifies the context type and ID, and optionally a starting track ID, whether to shuffle, and the repeat mode. The backend responds with a list of tracks in the order they should be played, along with metadata for each track. This allows the client to create dynamic playlists for continuous playback based on different contexts.
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
  } // to be changed wholly

  // -------------------------------------------------------------------------
  // 5.5  GET /me/listening-history
  // -------------------------------------------------------------------------
  // it retrieves the user's listening history, which is a list of tracks the user has played in the past, along with metadata such as when they were played and how long they were listened to. The client can specify pagination parameters (page and limit) to control how many history items are returned at once. This allows the user to view their past listening activity and can also be used for features like recently played tracks or personalized recommendations based on listening habits.
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
  // The backend may wrap responses in an optional { data: ... } envelope, so we need to unwrap it if present. This is a common pattern in APIs to allow for additional metadata alongside the main response data.
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

  // The backend expects context types as lowercase strings, so we need to convert our enum values to the appropriate string format when making the request.
  // is this for building the playback queue based on context? Yes, when we call the buildPlaybackQueue method, we need to specify the context type (e.g. track, playlist, feed) as a string that the backend understands. This helper method converts our PlaybackContextType enum values to the corresponding lowercase strings that the API expects.
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
