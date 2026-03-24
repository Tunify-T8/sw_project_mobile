// Upload Feature Guide:
// Purpose: Use-case wrapper that exposes a single upload-related action to providers or controllers.
// Used by: Consumed across nearby upload data and domain files.
// Concerns: Multi-format support; Metadata engine.
import '../entities/track_metadata.dart';
import '../entities/uploaded_track.dart';
import '../repositories/upload_repository.dart';

/// Step 3 of the upload flow: finalize metadata after audio is uploaded.
/// Backend returns status=processing; poll waitUntilProcessed next.
class UploadTrackMetadataUsecase {
  final UploadRepository repository;
  const UploadTrackMetadataUsecase(this.repository);

  Future<UploadedTrack> call({
    required String trackId,
    required TrackMetadata metadata,
  }) {
    return repository.finalizeMetadata(trackId: trackId, metadata: metadata);
  }
}
