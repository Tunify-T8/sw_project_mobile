import '../entities/picked_upload_file.dart';
import '../entities/track_metadata.dart';
import '../entities/upload_cancellation_token.dart';
import '../entities/upload_quota.dart';
import '../entities/uploaded_track.dart';
//contract for the upload repository,
//these are all the methods(business operations) which will be implemented by the data layer
// to be implemented by mock or real data source in their classes
//MockUploadRepository
//RealUploadRepository

abstract class UploadRepository {
  Future<UploadQuota> getUploadQuota(String userId);

  Future<UploadedTrack> createTrack(String userId);

  Future<UploadedTrack> uploadAudio({
    required String trackId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
    UploadCancellationToken? cancellationToken,
  });

  Future<UploadedTrack> finalizeMetadata({
    required String trackId,
    required TrackMetadata metadata,
  });

  Future<UploadedTrack> waitUntilProcessed(String trackId);

  Future<UploadedTrack> getTrackStatus(String trackId);

  Future<UploadedTrack> getTrackDetails(String trackId);

  Future<UploadedTrack> updateTrackMetadata({
    required String trackId,
    required TrackMetadata metadata,
  });

  Future<void> deleteTrack(String trackId);
}