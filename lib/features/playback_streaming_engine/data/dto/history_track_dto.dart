import 'track_artist_summary_dto.dart';

class HistoryTrackDto {
  const HistoryTrackDto({
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
  final TrackArtistSummaryDto artist;
  final String playedAt;
  final int durationSeconds;
  final String status;
  final int lastPositionSeconds;
  final String? coverUrl;
  final String? genre;
  final String? releaseDate;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int playCount;

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

    final rawPosition =
        json['lastPositionSeconds'] ??
        json['positionSeconds'] ??
        json['position'] ??
        json['lastPosition'] ??
        0;

    return HistoryTrackDto(
      trackId: (json['trackId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      artist: artist,
      playedAt: (json['playedAt'] ?? '') as String,
      durationSeconds: (json['durationSeconds'] as int?) ?? 0,
      status: resolvedStatus,
      lastPositionSeconds: rawPosition is num ? rawPosition.round() : 0,
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
    );
  }
}
