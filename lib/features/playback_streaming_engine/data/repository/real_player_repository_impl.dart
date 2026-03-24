import '../../domain/entities/history_track.dart';
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
  final StreamingApi _api;
  RealPlayerRepository(this._api);

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
  }) async {
    final dto = await _api.requestStreamUrl(trackId, quality: quality);
    return dto.toEntity();
  }

  @override
  Future<void> reportPlaybackEvent(PlaybackEvent event) {
    return _api.reportPlaybackEvent(
      trackId: event.trackId,
      action: event.action,
      positionSeconds: event.positionSeconds,
    );
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
    final dtos = await _api.getListeningHistory(page: page, limit: limit);
    return dtos.map((dto) => dto.toEntity()).toList();
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
