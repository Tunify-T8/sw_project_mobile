// Upload Feature Guide:
// Purpose: Use-case wrapper that exposes a single upload-related action to providers or controllers.
// Used by: library_uploads_repository_provider
// Concerns: Multi-format support.
import '../entities/upload_item.dart';
import '../repositories/library_uploads_repository.dart';

class GetMyUploadsUsecase {
  final LibraryUploadsRepository repository;

  const GetMyUploadsUsecase(this.repository);

  Future<List<UploadItem>> call() {
    return repository.getMyUploads();
  }
}
