import '../entities/upload_item.dart';
import '../repositories/library_uploads_repository.dart';

class GetMyUploadsUsecase {
  final LibraryUploadsRepository repository;

  const GetMyUploadsUsecase(this.repository);

  Future<List<UploadItem>> call() {
    return repository.getMyUploads();
  }
}