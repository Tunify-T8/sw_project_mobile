import 'track_artist_summary_dto.dart';

class HistoryTrackDto {
  const HistoryTrackDto({
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
  final TrackArtistSummaryDto artist;
  final String playedAt;
  final int durationSeconds;
  final String status;
  final String? coverUrl;
  final String? genre;
  final String? releaseDate;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int playCount;
  final int lastPositionSeconds;

  factory HistoryTrackDto.fromJson(Map<String, dynamic> json) {
    final artistJson = json['artist'];
    final engagementJson = json['engagement'];
    final playabilityJson = json['playability'];

    TrackArtistSummaryDto artist;
    if (artistJson is Map<String, dynamic>) {
      artist = TrackArtistSummaryDto.fromJson(artistJson);
    } else {
      final artistName = (artistJson ?? '') as String;
      artist = TrackArtistSummaryDto(
        id: '',
        name: artistName,
        tier: 'free',
      );
    }

    String resolvedStatus = 'playable';
    if (json['status'] is String) {
      resolvedStatus = json['status'] as String;
    } else if (playabilityJson is Map<String, dynamic> &&
        playabilityJson['status'] is String) {
      resolvedStatus = playabilityJson['status'] as String;
    }

    return HistoryTrackDto(
      trackId: (json['trackId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      artist: artist,
      playedAt: (json['playedAt'] ?? '') as String,
      durationSeconds: (json['durationSeconds'] as int?) ?? 0,
      status: resolvedStatus,
      coverUrl: json['coverUrl'] as String?,
      genre: json['genre'] as String?,
      releaseDate: json['releaseDate'] as String?,
      likeCount: engagementJson is Map<String, dynamic>
          ? (engagementJson['likeCount'] as int?) ?? 0
          : 0,
      commentCount: engagementJson is Map<String, dynamic>
          ? (engagementJson['commentCount'] as int?) ?? 0
          : 0,
      repostCount: engagementJson is Map<String, dynamic>
          ? (engagementJson['repostCount'] as int?) ?? 0
          : 0,
      playCount: engagementJson is Map<String, dynamic>
          ? (engagementJson['playCount'] as int?) ?? 0
          : 0,
      lastPositionSeconds:
          (json['lastPositionSeconds'] as int?) ??
          (json['positionSeconds'] as int?) ??
          (json['position'] as int?) ??
          0,
    );
  }
}
