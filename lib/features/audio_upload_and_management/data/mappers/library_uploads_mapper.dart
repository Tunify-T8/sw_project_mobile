import '../../domain/entities/artist_tools_quota.dart';
import '../../domain/entities/upload_item.dart';
import '../dto/artist_tools_quota_dto.dart';
import '../dto/upload_item_dto.dart';

extension UploadItemDtoMapper on UploadItemDto {
  UploadItem toEntity() {
    return UploadItem(
      id: id,
      title: title,
      artistDisplay: artists.join(', '),
      durationLabel: _formatDuration(durationSeconds),
      durationSeconds: durationSeconds,
      artworkUrl: artworkUrl,
      visibility:
          privacy == 'public' ? UploadVisibility.public : UploadVisibility.private,
      status: _mapStatus(status),
      isExplicit: contentWarning,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  static UploadProcessingStatus _mapStatus(String value) {
    switch (value) {
      case 'processing':
      case 'uploading':
        return UploadProcessingStatus.processing;
      case 'failed':
        return UploadProcessingStatus.failed;
      case 'deleted':
        return UploadProcessingStatus.deleted;
      case 'finished':
      default:
        return UploadProcessingStatus.finished;
    }
  }

  static String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

extension ArtistToolsQuotaDtoMapper on ArtistToolsQuotaDto {
  ArtistToolsQuota toEntity() {
    return ArtistToolsQuota(
      tier: tier == 'pro' ? ArtistTier.pro : ArtistTier.free,
      uploadMinutesLimit: uploadMinutesLimit,
      uploadMinutesUsed: uploadMinutesUsed,
      canReplaceFiles: canReplaceFiles,
      canUpgrade: canUpgrade,
    );
  }
}