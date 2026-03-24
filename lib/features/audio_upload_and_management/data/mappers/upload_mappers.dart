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
      errorCode: errorCode,
      errorMessage: errorMessage,
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
