import '../repositories/library_uploads_repository.dart';

class DeleteUploadUsecase {
  final LibraryUploadsRepository repository;

  const DeleteUploadUsecase(this.repository);

  Future<void> call(String trackId) {
    return repository.deleteUpload(trackId);
  }
}
