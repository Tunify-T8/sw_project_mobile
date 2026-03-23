import 'playback_status.dart';
import 'track_artist_summary.dart';

/// One entry in the user's listening history (GET /me/listening-history).
class HistoryTrack {
  const HistoryTrack({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.playedAt,
    required this.durationSeconds,
    required this.status,
  });

  final String trackId;
  final String title;
  final TrackArtistSummary artist;
  final DateTime playedAt;
  final int durationSeconds;
  final PlaybackStatus status;
}
