// Upload Feature Guide:
// Purpose: Translates mock upload service data into repository/domain-friendly models.
// Used by: mock_upload_repository_impl
// Concerns: Multi-format support.
import '../dto/track_response_dto.dart';
import '../mappers/upload_mappers.dart';
import '../../domain/entities/track_metadata.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';

Map<String, dynamic> buildMockTrackMetadataPayload(TrackMetadata metadata) {
  return {
    'title': metadata.title,
    'genreCategory': metadata.genreCategory,
    'genreSubGenre': metadata.genreSubGenre,
    'tags': metadata.tags,
    'description': metadata.description,
    'privacy': metadata.privacy,
    'artists': metadata.artists,
    'artworkPath': metadata.artworkPath,
    'recordLabel': metadata.recordLabel,
    'publisher': metadata.publisher,
    'isrc': metadata.isrc,
    'contentWarning': metadata.contentWarning,
    'scheduledReleaseDate': metadata.scheduledReleaseDate?.toIso8601String(),
    'allowDownloads': metadata.allowDownloads,
    'offlineListening': metadata.offlineListening,
    'includeInRss': metadata.includeInRss,
    'displayEmbedCode': metadata.displayEmbedCode,
    'appPlaybackEnabled': metadata.appPlaybackEnabled,
    'availabilityType': metadata.availabilityType,
    'availabilityRegions': metadata.availabilityRegions,
    'licensing': metadata.licensing,
    'pLine': metadata.pLine,
  };
}

UploadedTrack mapMockTrackResponse(Map<String, dynamic> data) {
  return TrackResponseDto.fromJson(data).toEntity();
}

UploadStatus mapMockUploadStatus(String value) {
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
