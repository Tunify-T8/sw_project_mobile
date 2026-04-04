import '../../domain/entities/history_track.dart';
import '../../domain/entities/playback_context_request.dart';
import '../../domain/entities/playback_event.dart';
import '../../domain/entities/playback_queue.dart';
import '../../domain/entities/playback_status.dart';
import '../../domain/entities/stream_url.dart';
import '../../domain/entities/track_playback_bundle.dart';
import '../../domain/repositories/player_repository.dart';
import '../api/streaming_api.dart';
import '../dto/history_track_dto.dart';
import '../dto/playback_context_response_dto.dart';
import '../dto/stream_response_dto.dart';
import '../dto/track_playback_bundle_dto.dart';
import '../mapper/playback_mapper.dart';
import '../services/mock_player_service.dart';

class MockPlayerRepository implements PlayerRepository {
  MockPlayerRepository({required this.service});

  final MockPlayerService service;

  @override
  Future<TrackPlaybackBundle> getPlaybackBundle(
    String trackId, {
    String? privateToken,
  }) async {
    final data = await service.getPlaybackBundle(
      trackId,
      privateToken: privateToken,
    );
    return TrackPlaybackBundleDto.fromJson(data).toEntity();
  }

  @override
  Future<StreamUrl> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
  }) async {
    final data = await service.requestStreamUrl(trackId, quality: quality);
    return StreamResponseDto.fromJson(data, trackId).toEntity();
  }

  @override
  Future<void> reportPlaybackEvent(PlaybackEvent event) {
    return service.reportPlaybackEvent(
      trackId: event.trackId,
      action: _actionToString(event.action),
      positionSeconds: event.positionSeconds,
    );
  }

  @override
  Future<PlaybackQueue> buildPlaybackQueue(
    PlaybackContextRequest request,
  ) async {
    final data = await service.buildPlaybackQueue(
      contextType: StreamingApi.contextTypeToString(request.contextType),
      contextId: request.contextId,
      startTrackId: request.startTrackId,
      shuffle: request.shuffle,
      repeat: _repeatToString(request.repeat),
    );
    return PlaybackContextResponseDto.fromJson(data).toEntity();
  }

  @override
  Future<List<HistoryTrack>> getListeningHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await service.getListeningHistory(page: page, limit: limit);
    final list = data['data'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(HistoryTrackDto.fromJson)
        .map((dto) => dto.toEntity())
        .toList();
  }

  @override
  Future<void> clearListeningHistory() {
    return service.clearListeningHistory();
  }

  @override
  Future<void> reportTrackCompleted(String trackId) async {}

  @override
  Future<void> addOfflinePlay(String trackId) async {}

  @override
  Future<void> markOfflinePlayCompleted(String trackId) async {}

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
