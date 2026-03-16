import '../../domain/entities/picked_upload_file.dart';
import '../../domain/entities/track_metadata.dart';
import '../../domain/entities/upload_quota.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';
import '../../domain/repositories/upload_repository.dart';
import '../services/mock_upload_service.dart';

//So repository’s job is:
// call service
// get raw map
// convert raw map into domain object
// This is exactly the translator layer.
//mapper for mock


class MockUploadRepository implements UploadRepository {
  final MockUploadService service;

  MockUploadRepository({
    required this.service,
  });

  @override
  Future<UploadQuota> getUploadQuota(String userId) async {
    final data = await service.getUploadQuota(userId: userId);

    return UploadQuota(
      tier: data['tier'] as String,
      uploadMinutesLimit: data['uploadMinutesLimit'] as int,
      uploadMinutesUsed: data['uploadMinutesUsed'] as int,
      uploadMinutesRemaining: data['uploadMinutesRemaining'] as int,
      canReplaceFiles: data['canReplaceFiles'] as bool,
      canScheduleRelease: data['canScheduleRelease'] as bool,
      canAccessAdvancedTab: data['canAccessAdvancedTab'] as bool,
    );
  }

  @override
  Future<UploadedTrack> createTrack(String userId) async {
    final data = await service.createTrack(userId: userId);

    return UploadedTrack(
      trackId: data['trackId'] as String,
      status: _mapStatus(data['status'] as String),
      audioUrl: data['audioUrl'] as String?,
      waveformUrl: data['waveformUrl'] as String?,
    );
  }

  @override
  Future<UploadedTrack> uploadAudio({
    required String trackId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
  }) async {
    await for (final progress in service.uploadProgress()) {
      onProgress(progress);
    }

final data = await service.uploadAudio(
  trackId: trackId,
  localFilePath: file.path,
);
    return UploadedTrack(
      trackId: data['trackId'] as String,
      status: _mapStatus(data['status'] as String),
      audioUrl: data['audioUrl'] as String?,
      waveformUrl: data['waveformUrl'] as String?,
    );
  }

  @override
  Future<UploadedTrack> finalizeMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    final data = await service.finalizeMetadata(
      trackId: trackId,
      metadata: {
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
      },
    );

    return UploadedTrack(
      trackId: data['trackId'] as String,
      status: _mapStatus(data['status'] as String),
      audioUrl: data['audioUrl'] as String?,
      waveformUrl: data['waveformUrl'] as String?,
      title: data['title'] as String?,
      description: data['description'] as String?,
      privacy: data['privacy'] as String?,
      artworkUrl: data['artworkUrl'] as String?,
    );
  }

  @override
  Future<UploadedTrack> waitUntilProcessed(String trackId) async {
    final data = await service.pollTrackStatus(trackId: trackId);

    return UploadedTrack(
      trackId: data['trackId'] as String,
      status: _mapStatus(data['status'] as String),
      audioUrl: data['audioUrl'] as String?,
      waveformUrl: data['waveformUrl'] as String?,
      artworkUrl: data['artworkUrl'] as String?,
    );
  }

  @override
  Future<UploadedTrack> getTrackDetails(String trackId) async {
    final data = await service.getTrackDetails(trackId: trackId);

    return UploadedTrack(
      trackId: data['trackId'] as String,
      status: _mapStatus(data['status'] as String),
      title: data['title'] as String?,
      description: data['description'] as String?,
      privacy: data['privacy'] as String?,
      audioUrl: data['audioUrl'] as String?,
      waveformUrl: data['waveformUrl'] as String?,
      artworkUrl: data['artworkUrl'] as String?,
      durationSeconds: data['durationSeconds'] as int?,
    );
  }

  @override
  Future<UploadedTrack> updateTrackMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    final data = await service.updateTrackMetadata(
      trackId: trackId,
      metadata: {
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
      },
    );

    return UploadedTrack(
      trackId: data['trackId'] as String,
      status: _mapStatus(data['status'] as String),
      audioUrl: data['audioUrl'] as String?,
      waveformUrl: data['waveformUrl'] as String?,
      title: data['title'] as String?,
      description: data['description'] as String?,
      privacy: data['privacy'] as String?,
      artworkUrl: data['artworkUrl'] as String?,
    );
  }

  @override
  Future<void> deleteTrack(String trackId) async {
    await service.deleteTrack(trackId: trackId);
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