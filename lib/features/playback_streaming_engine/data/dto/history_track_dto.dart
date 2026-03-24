import 'track_artist_summary_dto.dart';

class HistoryTrackDto {
  final String trackId;
  final String title;
  final TrackArtistSummaryDto artist;
  final String playedAt; // ISO 8601 timestamp of when the track was played
  final int durationSeconds;
  final String status; // e.g. "playable", "blocked", "unavailable"

  const HistoryTrackDto({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.playedAt,
    required this.durationSeconds,
    required this.status,
  });



  factory HistoryTrackDto.fromJson(Map<String, dynamic> json) {
    final artistJson = json['artist'];
    return HistoryTrackDto(
      trackId: (json['trackId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      artist: artistJson is Map<String, dynamic>
          ? TrackArtistSummaryDto.fromJson(artistJson)
          : const TrackArtistSummaryDto(id: '', name: '', tier: 'free'),
      playedAt: (json['playedAt'] ?? '') as String,
      durationSeconds: (json['durationSeconds'] as int?) ?? 0,
      status: (json['status'] ?? 'playable') as String,
    );
  }
}
