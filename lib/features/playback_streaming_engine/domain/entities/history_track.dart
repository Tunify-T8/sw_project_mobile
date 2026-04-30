import 'playback_status.dart';
import 'track_artist_summary.dart';

/// One entry in the user's listening history.
///
/// [lastPositionSeconds] is stored locally by Flutter. It lets Recently Played
/// and Listening History resume from where the user actually stopped, without
/// depending on a backend progress endpoint.
class HistoryTrack {
  const HistoryTrack({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.playedAt,
    required this.durationSeconds,
    required this.status,
    this.lastPositionSeconds = 0,
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
  final int lastPositionSeconds;
  final String? coverUrl;
  final String? genre;
  final DateTime? releaseDate;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int playCount;

  HistoryTrack copyWith({
    String? trackId,
    String? title,
    TrackArtistSummary? artist,
    DateTime? playedAt,
    int? durationSeconds,
    PlaybackStatus? status,
    int? lastPositionSeconds,
    String? coverUrl,
    String? genre,
    DateTime? releaseDate,
    int? likeCount,
    int? commentCount,
    int? repostCount,
    int? playCount,
  }) {
    return HistoryTrack(
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      playedAt: playedAt ?? this.playedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      lastPositionSeconds: lastPositionSeconds ?? this.lastPositionSeconds,
      coverUrl: coverUrl ?? this.coverUrl,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      repostCount: repostCount ?? this.repostCount,
      playCount: playCount ?? this.playCount,
    );
  }
}
