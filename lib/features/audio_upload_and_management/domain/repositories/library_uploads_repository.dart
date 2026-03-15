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
}