import '../repositories/library_uploads_repository.dart';

class ReplaceFileUsecase {
  final LibraryUploadsRepository repository;

  const ReplaceFileUsecase(this.repository);

  Future<void> call({
    required String trackId,
    required String filePath,
  }) {
    return repository.replaceUploadFile(
      trackId: trackId,
      filePath: filePath,
    );
  }
}