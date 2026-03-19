import '../../domain/entities/picked_upload_file.dart';
import '../../domain/entities/track_metadata.dart';
import '../../domain/entities/upload_cancellation_token.dart';
import '../../domain/entities/upload_quota.dart';
import '../../domain/entities/uploaded_track.dart';
import '../../domain/repositories/upload_repository.dart';
import '../services/cloudinary_media_service.dart';
import 'cloudinary_upload_workflow.dart';

class CloudinaryUploadRepository implements UploadRepository {
  CloudinaryUploadRepository(CloudinaryMediaService mediaService)
    : _workflow = CloudinaryUploadWorkflow(mediaService);

  final CloudinaryUploadWorkflow _workflow;

  @override
  Future<UploadQuota> getUploadQuota(String userId) =>
      _workflow.getUploadQuota(userId);

  @override
  Future<UploadedTrack> createTrack(String userId) =>
      _workflow.createTrack(userId);

  @override
  Future<UploadedTrack> uploadAudio({
    required String trackId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
    UploadCancellationToken? cancellationToken,
  }) {
    return _workflow.uploadAudio(
      trackId: trackId,
      file: file,
      onProgress: onProgress,
      cancellationToken: cancellationToken,
    );
  }

  @override
  Future<UploadedTrack> finalizeMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) {
    return _workflow.finalizeMetadata(trackId: trackId, metadata: metadata);
  }

  @override
  Future<UploadedTrack> waitUntilProcessed(String trackId) {
    return _workflow.waitUntilProcessed(trackId);
  }

  @override
  Future<UploadedTrack> getTrackDetails(String trackId) {
    return _workflow.getTrackDetails(trackId);
  }

  @override
  Future<UploadedTrack> updateTrackMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) {
    return _workflow.updateTrackMetadata(trackId: trackId, metadata: metadata);
  }

  @override
  Future<void> deleteTrack(String trackId) => _workflow.deleteTrack(trackId);
}
