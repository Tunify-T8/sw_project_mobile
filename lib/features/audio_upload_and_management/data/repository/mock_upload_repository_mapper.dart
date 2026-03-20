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
  return UploadedTrack(
    trackId: data['trackId'] as String,
    status: mapMockUploadStatus(data['status'] as String),
    audioUrl: data['audioUrl'] as String?,
    waveformUrl: data['waveformUrl'] as String?,
    title: data['title'] as String?,
    description: data['description'] as String?,
    privacy: data['privacy'] as String?,
    artworkUrl: data['artworkUrl'] as String?,
    durationSeconds: data['durationSeconds'] as int?,
  );
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
