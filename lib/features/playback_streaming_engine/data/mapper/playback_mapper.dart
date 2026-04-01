import '../../domain/entities/history_track.dart';
import '../../domain/entities/playability_info.dart';
import '../../domain/entities/playback_queue.dart';
import '../../domain/entities/playback_status.dart';
import '../../domain/entities/preview_info.dart';
import '../../domain/entities/stream_url.dart';
import '../../domain/entities/track_artist_summary.dart';
import '../../domain/entities/track_engagement.dart';
import '../../domain/entities/track_playback_bundle.dart';
import '../dto/history_track_dto.dart';
import '../dto/playability_status_dto.dart';
import '../dto/playback_context_response_dto.dart';
import '../dto/preview_info_dto.dart';
import '../dto/stream_response_dto.dart';
import '../dto/track_artist_summary_dto.dart';
import '../dto/track_engagement_dto.dart';
import '../dto/track_playback_bundle_dto.dart';


extension TrackPlaybackBundleDtoMapper on TrackPlaybackBundleDto {
  TrackPlaybackBundle toEntity() {
    return TrackPlaybackBundle(
      trackId: trackId,
      title: title,
      artist: artist.toEntity(),
      durationSeconds: durationSeconds,
      waveformUrl: waveformUrl,
      coverUrl: coverUrl,
      contentWarning: contentWarning,
      engagement: engagement.toEntity(),
      playability: playability.toEntity(),
      preview: preview.toEntity(),
      scheduledReleaseDate: scheduledReleaseDate != null
          ? DateTime.tryParse(scheduledReleaseDate!)
          : null,
    );
  }
}

extension TrackArtistSummaryDtoMapper on TrackArtistSummaryDto {
  TrackArtistSummary toEntity() {
    return TrackArtistSummary(id: id, name: name, tier: tier);
  }
}

extension TrackEngagementDtoMapper on TrackEngagementDto {
  TrackEngagement toEntity() {
    return TrackEngagement(
      likeCount: likeCount,
      commentCount: commentCount,
      repostCount: repostCount,
      isLiked: isLiked,
      isReposted: isReposted,
      isSaved: isSaved,
    );
  }
}

extension PlayabilityStatusDtoMapper on PlayabilityStatusDto {
  PlayabilityInfo toEntity() {
    return PlayabilityInfo(
      status: _mapStatus(status),
      regionBlocked: regionBlocked,
      tierBlocked: tierBlocked,
      requiresSubscription: requiresSubscription,
      blockedReason: blockedReason != null
          ? _mapBlockedReason(blockedReason!)
          : null,
    );
  }

  static PlaybackStatus _mapStatus(String raw) {
    switch (raw) {
      case 'playable':
        return PlaybackStatus.playable;
      case 'preview':
        return PlaybackStatus.preview;
      case 'blocked':
      default:
        return PlaybackStatus.blocked;
    }
  }

  static BlockedReason? _mapBlockedReason(String raw) {
    switch (raw) {
      case 'region_restricted':
        return BlockedReason.regionRestricted;
      case 'tier_restricted':
        return BlockedReason.tierRestricted;
      case 'scheduled_release':
        return BlockedReason.scheduledRelease;
      case 'deleted':
        return BlockedReason.deleted;
      case 'private_no_token':
        return BlockedReason.privateNoToken;
      case 'copyright':
        return BlockedReason.copyright;
      default:
        return null;
    }
  }
}

extension PreviewInfoDtoMapper on PreviewInfoDto {
  PreviewInfo toEntity() {
    return PreviewInfo(
      enabled: enabled,
      previewDurationSeconds: previewDurationSeconds,
      previewStartSeconds: previewStartSeconds,
    );
  }
}

extension StreamResponseDtoMapper on StreamResponseDto {
  StreamUrl toEntity() {
    return StreamUrl(
      trackId: trackId,
      url: url,
      expiresInSeconds: expiresInSeconds,
      format: format,
    );
  }
}

extension PlaybackContextResponseDtoMapper on PlaybackContextResponseDto {
  PlaybackQueue toEntity() {
    return PlaybackQueue(
      trackIds: trackIds,
      currentIndex: currentIndex,
      shuffle: shuffle,
      repeat: _mapRepeat(repeat),
    );
  }

  static RepeatMode _mapRepeat(String raw) {
    switch (raw) {
      case 'one':
        return RepeatMode.one;
      case 'all':
        return RepeatMode.all;
      case 'none':
      default:
        return RepeatMode.none;
    }
  }
}

extension HistoryTrackDtoMapper on HistoryTrackDto {
  HistoryTrack toEntity() {
    return HistoryTrack(
      trackId: trackId,
      title: title,
      artist: artist.toEntity(),
      playedAt: DateTime.tryParse(playedAt) ?? DateTime.now(),
      durationSeconds: durationSeconds,
      status: _mapStatus(status),
      coverUrl: coverUrl,
      genre: genre,
      releaseDate: releaseDate != null ? DateTime.tryParse(releaseDate!) : null,
      likeCount: likeCount,
      commentCount: commentCount,
      repostCount: repostCount,
      playCount: playCount,
    );
  }

  static PlaybackStatus _mapStatus(String raw) {
    switch (raw) {
      case 'playable':
        return PlaybackStatus.playable;
      case 'preview':
        return PlaybackStatus.preview;
      case 'blocked':
      default:
        return PlaybackStatus.blocked;
    }
  }
}
