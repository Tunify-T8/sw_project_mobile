// Upload Feature Guide:
// Purpose: Repository contract that the upload feature depends on from the domain layer.
// Used by: library_uploads_repository_impl, delete_upload_usecase, get_artist_tools_quota_usecase, and 4 more upload files.
// Concerns: Multi-format support; Track visibility.
import '../entities/artist_tools_quota.dart';
import '../entities/upload_item.dart';

abstract class LibraryUploadsRepository {
  Future<List<UploadItem>> getMyUploads();
  Future<ArtistToolsQuota> getArtistToolsQuota();
  Future<void> deleteUpload(String trackId);
  Future<void> replaceUploadFile({
    required String trackId,
    required String filePath,
  });
  Future<UploadItem> updateUpload({
    required String trackId,
    required String title,
    required String description,
    required String privacy,
    String? localArtworkPath,
  });
}
