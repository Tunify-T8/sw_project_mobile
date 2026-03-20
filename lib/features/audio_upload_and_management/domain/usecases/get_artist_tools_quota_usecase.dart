import '../entities/artist_tools_quota.dart';
import '../repositories/library_uploads_repository.dart';

class GetArtistToolsQuotaUsecase {
  final LibraryUploadsRepository repository;

  const GetArtistToolsQuotaUsecase(this.repository);

  Future<ArtistToolsQuota> call() {
    return repository.getArtistToolsQuota();
  }
}
