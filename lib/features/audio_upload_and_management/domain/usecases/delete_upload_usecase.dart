// Upload Feature Guide:
// Purpose: Use-case wrapper that exposes a single upload-related action to providers or controllers.
// Used by: library_uploads_repository_provider
// Concerns: Multi-format support; Track visibility.
import '../repositories/library_uploads_repository.dart';

class DeleteUploadUsecase {
  final LibraryUploadsRepository repository;

  const DeleteUploadUsecase(this.repository);

  Future<void> call(String trackId) {
    return repository.deleteUpload(trackId);
  }
}
