// Upload Feature Guide:
// Purpose: Use-case wrapper that exposes a single upload-related action to providers or controllers.
// Used by: library_uploads_repository_provider
// Concerns: Track visibility.
import '../repositories/library_uploads_repository.dart';

class ReplaceFileUsecase {
  final LibraryUploadsRepository repository;

  const ReplaceFileUsecase(this.repository);

  Future<void> call({required String trackId, required String filePath}) {
    return repository.replaceUploadFile(trackId: trackId, filePath: filePath);
  }
}
