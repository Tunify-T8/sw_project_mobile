import '../entities/upload_item.dart';
import '../repositories/library_uploads_repository.dart';

class UpdateUploadUsecase {
  final LibraryUploadsRepository repository;
  const UpdateUploadUsecase(this.repository);

  Future<UploadItem> call({
    required String trackId,
    required String title,
    required String description,
    required String privacy,
    String? localArtworkPath,
  }) {
    return repository.updateUpload(
      trackId: trackId,
      title: title,
      description: description,
      privacy: privacy,
      localArtworkPath: localArtworkPath,
    );
  }
}
