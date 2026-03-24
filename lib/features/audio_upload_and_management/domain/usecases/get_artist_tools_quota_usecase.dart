// Upload Feature Guide:
// Purpose: Use-case wrapper that exposes a single upload-related action to providers or controllers.
// Used by: library_uploads_repository_provider
// Concerns: Supporting UI and infrastructure for upload and track management.
import '../entities/artist_tools_quota.dart';
import '../repositories/library_uploads_repository.dart';

class GetArtistToolsQuotaUsecase {
  final LibraryUploadsRepository repository;

  const GetArtistToolsQuotaUsecase(this.repository);

  Future<ArtistToolsQuota> call() {
    return repository.getArtistToolsQuota();
  }
}
