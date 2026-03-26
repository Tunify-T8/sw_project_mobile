import 'playability_info.dart';
import 'preview_info.dart';
import 'track_artist_summary.dart';
import 'track_engagement.dart';

/// Full bundle returned when opening the player screen.
/// Maps 1-to-1 with the API's TrackPlaybackBundle schema.
class TrackPlaybackBundle {
  const TrackPlaybackBundle({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.durationSeconds,
    required this.waveformUrl,
    required this.coverUrl,
    required this.contentWarning,
    required this.engagement,
    required this.playability,
    required this.preview,
    this.scheduledReleaseDate,
  });

  final String trackId;
  final String title;
  final TrackArtistSummary artist;
  final int durationSeconds;
  final String waveformUrl;
  final String coverUrl;
  final bool contentWarning;
  final TrackEngagement engagement;
  final PlayabilityInfo playability;
  final PreviewInfo preview;
  final DateTime? scheduledReleaseDate;

  TrackPlaybackBundle copyWith({
    String? trackId,
    String? title,
    TrackArtistSummary? artist,
    int? durationSeconds,
    String? waveformUrl,
    String? coverUrl,
    bool? contentWarning,
    TrackEngagement? engagement,
    PlayabilityInfo? playability,
    PreviewInfo? preview,
    DateTime? scheduledReleaseDate,
  }) {
    return TrackPlaybackBundle(
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      waveformUrl: waveformUrl ?? this.waveformUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      contentWarning: contentWarning ?? this.contentWarning,
      engagement: engagement ?? this.engagement,
      playability: playability ?? this.playability,
      preview: preview ?? this.preview,
      scheduledReleaseDate: scheduledReleaseDate ?? this.scheduledReleaseDate,
    );
  }
}
