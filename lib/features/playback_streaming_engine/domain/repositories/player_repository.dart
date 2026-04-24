import '../entities/history_track.dart';
import '../entities/offline_play_record.dart';
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

  /// GET /tracks/{trackId}/stream
  /// Issues a signed, time-limited streaming URL.
  /// [quality]: 'auto' | '128' | '320'
  /// Pass [privateToken] for private tracks shared via link.
  Future<StreamUrl> requestStreamUrl(String trackId, {String quality = 'auto', String? privateToken});

  /// Playback event reporting.
  ///
  /// The current backend used by your app no longer exposes the old
  /// `/me/playback/events` endpoint, so implementations may safely treat this
  /// as a no-op.
  Future<void> reportPlaybackEvent(PlaybackEvent event);

  /// POST /playback/context
  /// Resolves a source context into an ordered queue of track IDs.
  Future<PlaybackQueue> buildPlaybackQueue(PlaybackContextRequest request);

  /// GET /me/listening-history
  Future<List<HistoryTrack>> getListeningHistory({
    int page = 1,
    int limit = 20,
  });

  /// Clears listening history.
  ///
  /// When the backend has no clear-history endpoint yet, implementations may do
  /// nothing and let the presentation layer handle the clear locally.
  Future<void> clearListeningHistory();

  /// POST /tracks/{trackId}/played
  /// Called once when the user reaches 90 % of a track naturally (not on skip).
  Future<void> reportTrackCompleted(String trackId);

  /// Adds a play that happened while offline to the local pending queue.
  /// The queue is flushed via `POST /tracks/plays/batch` when back online.
  Future<void> addOfflinePlay(String trackId);

  /// Marks the pending offline play for [trackId] as completed (90 % reached).
  Future<void> markOfflinePlayCompleted(String trackId);
}
