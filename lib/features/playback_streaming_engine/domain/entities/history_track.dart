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
    this.lastPositionSeconds = 0,
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

  /// Local resume position used by Flutter when the backend does not provide
  /// playback-progress support. This is saved in secure storage with the
  /// listening-history cache.
  final int lastPositionSeconds;

  HistoryTrack copyWith({
    String? trackId,
    String? title,
    TrackArtistSummary? artist,
    DateTime? playedAt,
    int? durationSeconds,
    PlaybackStatus? status,
    String? coverUrl,
    String? genre,
    DateTime? releaseDate,
    int? likeCount,
    int? commentCount,
    int? repostCount,
    int? playCount,
    int? lastPositionSeconds,
  }) {
    return HistoryTrack(
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      playedAt: playedAt ?? this.playedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      coverUrl: coverUrl ?? this.coverUrl,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      repostCount: repostCount ?? this.repostCount,
      playCount: playCount ?? this.playCount,
      lastPositionSeconds: lastPositionSeconds ?? this.lastPositionSeconds,
    );
  }
}
