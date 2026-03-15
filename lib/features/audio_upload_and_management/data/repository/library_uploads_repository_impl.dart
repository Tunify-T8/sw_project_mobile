import '../../domain/entities/artist_tools_quota.dart';
import '../../domain/entities/upload_item.dart';
import '../../domain/repositories/library_uploads_repository.dart';
import '../api/library_uploads_api.dart';
import '../api/mock_library_uploads_api.dart';
import '../mappers/library_uploads_mapper.dart';

class LibraryUploadsRepositoryImpl implements LibraryUploadsRepository {
  final LibraryUploadsApi api;
  final MockLibraryUploadsApi mockApi;
  final bool useMock;

  const LibraryUploadsRepositoryImpl({
    required this.api,
    required this.mockApi,
    required this.useMock,
  });

  @override
  Future<List<UploadItem>> getMyUploads() async {
    final dtos = useMock ? await mockApi.getMyUploads() : await api.getMyUploads();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<ArtistToolsQuota> getArtistToolsQuota() async {
    final dto = useMock
        ? await mockApi.getArtistToolsQuota()
        : await api.getArtistToolsQuota();

    return dto.toEntity();
  }

  @override
  Future<void> deleteUpload(String trackId) async {
    if (useMock) {
      await mockApi.deleteUpload(trackId);
      return;
    }

    await api.deleteUpload(trackId);
  }

  @override
  Future<void> replaceUploadFile({
    required String trackId,
    required String filePath,
  }) async {
    if (useMock) {
      await mockApi.replaceUploadFile(
        trackId: trackId,
        filePath: filePath,
      );
      return;
    }

    await api.replaceUploadFile(
      trackId: trackId,
      filePath: filePath,
    );
  }
}