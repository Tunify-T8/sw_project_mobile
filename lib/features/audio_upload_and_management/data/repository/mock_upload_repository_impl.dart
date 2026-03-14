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
      canUpgrade: data['canUpgrade'] as bool,
    );
  }

  @override
  Future<UploadedTrack> createTrack(String userId) async {
    final data = await service.createTrack(userId: userId);

    return UploadedTrack(
      trackId: data['trackId'] as String,
      status: UploadStatus.idle,
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

    final data = await service.uploadAudio(trackId: trackId);

    return UploadedTrack(
      trackId: data['trackId'] as String,
      status: UploadStatus.uploading,
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
      },
    );

    return UploadedTrack(
      trackId: data['trackId'] as String,
      status: UploadStatus.processing,
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
      status: UploadStatus.finished,
      audioUrl: data['audioUrl'] as String?,
      waveformUrl: data['waveformUrl'] as String?,
      artworkUrl: data['artworkUrl'] as String?,
    );
  }

  @override
  Future<UploadedTrack> getTrackDetails(String trackId) async {
    return waitUntilProcessed(trackId);
  }

  @override
  Future<UploadedTrack> updateTrackMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    return finalizeMetadata(trackId: trackId, metadata: metadata);
  }

  @override
  Future<void> deleteTrack(String trackId) async {}
}
