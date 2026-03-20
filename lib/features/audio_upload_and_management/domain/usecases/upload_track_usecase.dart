import '../entities/picked_upload_file.dart';
import '../entities/uploaded_track.dart';
import '../repositories/upload_repository.dart';

/// Step 1 + 2 of the upload flow:
/// Creates a draft track on the backend, then uploads the binary audio.
class UploadTrackUsecase {
  final UploadRepository repository;
  const UploadTrackUsecase(this.repository);

  Future<UploadedTrack> call({
    required String userId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
  }) async {
    final draft = await repository.createTrack(userId);
    return repository.uploadAudio(
      trackId: draft.trackId,
      file: file,
      onProgress: onProgress,
    );
  }
}
