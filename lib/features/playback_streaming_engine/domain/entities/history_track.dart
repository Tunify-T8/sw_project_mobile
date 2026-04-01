import 'playback_status.dart';
import 'track_artist_summary.dart';

/// One entry in the user's listening history.
class HistoryTrack {
  const HistoryTrack({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.playedAt,
    required this.durationSeconds,
    required this.status,
    this.coverUrl,
    this.genre,
    this.releaseDate,
    this.likeCount = 0,
    this.commentCount = 0,
    this.repostCount = 0,
    this.playCount = 0,
  });

  final String trackId;
  final String title;
  final TrackArtistSummary artist;
  final DateTime playedAt;
  final int durationSeconds;
  final PlaybackStatus status;
  final String? coverUrl;
  final String? genre;
  final DateTime? releaseDate;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int playCount;
}
