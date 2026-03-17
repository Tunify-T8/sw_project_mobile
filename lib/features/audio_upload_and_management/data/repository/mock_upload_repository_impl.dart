import '../../domain/entities/picked_upload_file.dart';
import '../../domain/entities/track_metadata.dart';
import '../../domain/entities/upload_quota.dart';
import '../../domain/entities/uploaded_track.dart';
import '../../domain/repositories/upload_repository.dart';
import '../services/mock_upload_service.dart';
import 'mock_upload_repository_mapper.dart';

class MockUploadRepository implements UploadRepository {
  MockUploadRepository({required this.service});

  final MockUploadService service;

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
    return mapMockTrackResponse(data);
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
    return mapMockTrackResponse(data);
  }

  @override
  Future<UploadedTrack> finalizeMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    final data = await service.finalizeMetadata(
      trackId: trackId,
      metadata: buildMockTrackMetadataPayload(metadata),
    );
    return mapMockTrackResponse(data);
  }

  @override
  Future<UploadedTrack> waitUntilProcessed(String trackId) async {
    final data = await service.pollTrackStatus(trackId: trackId);
    return mapMockTrackResponse(data);
  }

  @override
  Future<UploadedTrack> getTrackDetails(String trackId) async {
    final data = await service.getTrackDetails(trackId: trackId);
    return mapMockTrackResponse(data);
  }

  @override
  Future<UploadedTrack> updateTrackMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    final data = await service.updateTrackMetadata(
      trackId: trackId,
      metadata: buildMockTrackMetadataPayload(metadata),
    );
    return mapMockTrackResponse(data);
  }

  @override
  Future<void> deleteTrack(String trackId) async {
    await service.deleteTrack(trackId: trackId);
  }
}
