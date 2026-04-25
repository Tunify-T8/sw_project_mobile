// Upload Feature Guide:
// Purpose: Mapper/helper file that converts upload data between API, domain, and UI shapes.
// Used by: real_upload_repository_impl
// Concerns: Multi-format support.
import '../../domain/entities/upload_quota.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';
import '../dto/track_response_dto.dart';
import '../dto/upload_quota_dto.dart';

extension UploadQuotaDtoMapper on UploadQuotaDto {
  UploadQuota toEntity() {
    return UploadQuota(
      tier: tier,
      uploadMinutesLimit: uploadMinutesLimit,
      uploadMinutesUsed: uploadMinutesUsed,
      uploadMinutesRemaining: uploadMinutesRemaining,
      canReplaceFiles: canReplaceFiles,
      canScheduleRelease: canScheduleRelease,
      canAccessAdvancedTab: canAccessAdvancedTab,
    );
  }
}

extension TrackResponseDtoMapper on TrackResponseDto {
  UploadedTrack toEntity() {
    return UploadedTrack(
      trackId: trackId,
      status: _mapStatus(status),
      audioUrl: audioUrl,
      waveformUrl: waveformUrl,
      title: title,
      description: description,
      privacy: privacy,
      artworkUrl: artworkUrl,
      durationSeconds: durationSeconds,
      artists: artists ?? const [],
      tags: tags == null ? null : List<String>.from(tags!),
      genreCategory: genreCategory,
      genreSubGenre: genreSubGenre,
      recordLabel: recordLabel,
      publisher: publisher,
      isrc: isrc,
      pLine: pLine,
      contentWarning: contentWarning,
      scheduledReleaseDate: scheduledReleaseDate == null
          ? null
          : DateTime.tryParse(scheduledReleaseDate!),
      allowDownloads: permissions?.enableDirectDownloads,
      offlineListening: permissions?.enableOfflineListening,
      includeInRss: permissions?.includeInRSS,
      displayEmbedCode: permissions?.displayEmbedCode,
      appPlaybackEnabled: permissions?.enableAppPlayback,
      availabilityType: availability?.type,
      availabilityRegions: availability == null
          ? null
          : List<String>.from(availability!.regions),
      licensing: licensing?.type,
      errorCode: errorCode,
      errorMessage: errorMessage,
      privateToken: _readPrivateToken(this),
    );
  }

  UploadStatus _mapStatus(String value) {
    switch (value) {
      case 'idle':
        return UploadStatus.idle;
      case 'uploading':
        return UploadStatus.uploading;
      case 'processing':
        return UploadStatus.processing;
      case 'finished':
        return UploadStatus.finished;
      case 'failed':
        return UploadStatus.failed;
      case 'deleted':
        return UploadStatus.deleted;
      default:
        return UploadStatus.failed;
    }
  }
}

String? _readPrivateToken(TrackResponseDto dto) {
  final rawToken = dto.rawJson?['privateToken'];
  if (rawToken is String && rawToken.trim().isNotEmpty) {
    return rawToken.trim();
  }

  try {
    final dynamic dynamicDto = dto;
    final token = dynamicDto.privateToken;
    if (token is String && token.trim().isNotEmpty) {
      return token.trim();
    }
  } catch (_) {
    // Older generated/test DTO shapes may not expose privateToken directly.
  }

  return null;
}
