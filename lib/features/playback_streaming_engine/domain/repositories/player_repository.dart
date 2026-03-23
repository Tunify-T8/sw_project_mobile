import '../entities/history_track.dart';
import '../entities/playback_context_request.dart';
import '../entities/playback_event.dart';
import '../entities/playback_queue.dart';
import '../entities/stream_url.dart';
import '../entities/track_playback_bundle.dart';

/// Contract for all playback & streaming operations.
/// Implemented by [MockPlayerRepository] and [RealPlayerRepository].
abstract class PlayerRepository {
  /// GET /tracks/{trackId}/playback
  /// Returns full bundle needed to render the player screen.
  /// Pass [privateToken] for private tracks shared via link.
  Future<TrackPlaybackBundle> getPlaybackBundle(
    String trackId, {
    String? privateToken,
  });

  /// POST /tracks/{trackId}/stream
  /// Issues a signed, time-limited streaming URL.
  /// [quality]: 'auto' | '128' | '320'
  Future<StreamUrl> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
  });

  /// PATCH /me/playback/events
  /// Reports a play / progress / pause event to the backend.
  Future<void> reportPlaybackEvent(PlaybackEvent event);

  /// POST /playback/context
  /// Resolves a source context into an ordered queue of track IDs.
  Future<PlaybackQueue> buildPlaybackQueue(PlaybackContextRequest request);

  /// GET /me/listening-history
  Future<List<HistoryTrack>> getListeningHistory({
    int page = 1,
    int limit = 20,
  });
}
