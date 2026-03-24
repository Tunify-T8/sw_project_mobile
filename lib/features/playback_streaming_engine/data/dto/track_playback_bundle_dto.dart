import 'playability_status_dto.dart';
import 'preview_info_dto.dart';
import 'track_artist_summary_dto.dart';
import 'track_engagement_dto.dart';

class TrackPlaybackBundleDto {
  const TrackPlaybackBundleDto({
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
  final TrackArtistSummaryDto artist;
  final int durationSeconds;
  final String waveformUrl;
  final String coverUrl;
  final bool contentWarning;
  final TrackEngagementDto engagement;
  final PlayabilityStatusDto playability;
  final PreviewInfoDto preview;
  final String? scheduledReleaseDate;

  factory TrackPlaybackBundleDto.fromJson(Map<String, dynamic> json) {
    // Unwrap potential { data: {...} } envelope
    final map = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final artistJson = map['artist'];
    final engagementJson = map['engagement'];
    final playabilityJson = map['playability'];
    final previewJson = map['preview'];

    return TrackPlaybackBundleDto(
      trackId: (map['trackId'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      artist: artistJson is Map<String, dynamic>
          ? TrackArtistSummaryDto.fromJson(artistJson)
          : const TrackArtistSummaryDto(id: '', name: '', tier: 'free'),
      durationSeconds: (map['durationSeconds'] as int?) ?? 0,
      waveformUrl: (map['waveformUrl'] ?? '') as String,
      coverUrl: (map['coverUrl'] ?? map['artworkUrl'] ?? '') as String,
      contentWarning: (map['contentWarning'] as bool?) ?? false,
      engagement: engagementJson is Map<String, dynamic>
          ? TrackEngagementDto.fromJson(engagementJson)
          : const TrackEngagementDto(
              likeCount: 0,
              commentCount: 0,
              repostCount: 0,
              isLiked: false,
              isReposted: false,
              isSaved: false,
            ),
      playability: playabilityJson is Map<String, dynamic>
          ? PlayabilityStatusDto.fromJson(playabilityJson)
          : const PlayabilityStatusDto(
              status: 'playable',
              regionBlocked: false,
              tierBlocked: false,
              requiresSubscription: false,
            ),
      preview: previewJson is Map<String, dynamic>
          ? PreviewInfoDto.fromJson(previewJson)
          : const PreviewInfoDto(
              enabled: false,
              previewDurationSeconds: 30,
              previewStartSeconds: 0,
            ),
      scheduledReleaseDate: map['scheduledReleaseDate'] as String?,
    );
  }
}
