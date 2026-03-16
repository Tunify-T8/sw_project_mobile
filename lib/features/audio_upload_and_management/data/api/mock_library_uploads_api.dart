import '../dto/artist_tools_quota_dto.dart';
import '../dto/upload_item_dto.dart';
import '../services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';

/// Mock API for the Library / Your Uploads screen.
/// Starts EMPTY — tracks only appear after the user uploads them via the upload flow.
/// Reads/writes from GlobalTrackStore which is the single source of truth.
class MockLibraryUploadsApi {
  MockLibraryUploadsApi();

  Future<List<UploadItemDto>> getMyUploads() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return GlobalTrackStore.instance.all
        .where((item) => !item.isDeleted)
        .map((item) => UploadItemDto(
              id: item.id,
              title: item.title,
              artists: item.artistDisplay.split(', '),
              durationSeconds: item.durationSeconds,
              artworkUrl: item.artworkUrl,
              localArtworkPath: item.localArtworkPath,
              localFilePath: item.localFilePath,
              description: item.description,
              privacy:
                  item.visibility == UploadVisibility.public ? 'public' : 'private',
              status: _statusString(item.status),
              contentWarning: item.isExplicit,
              createdAt: item.createdAt.toIso8601String(),
            ))
        .toList();
  }

  Future<ArtistToolsQuotaDto> getArtistToolsQuota() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const ArtistToolsQuotaDto(
      tier: 'free',
      uploadMinutesLimit: 180,
      uploadMinutesUsed: 8,
      canReplaceFiles: false,
      canUpgrade: true,
    );
  }

  Future<void> deleteUpload(String trackId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    GlobalTrackStore.instance.remove(trackId);
  }

  Future<void> replaceUploadFile({
    required String trackId,
    required String filePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final existing = GlobalTrackStore.instance.find(trackId);
    if (existing != null) {
      GlobalTrackStore.instance.update(existing.copyWith(
        localFilePath: filePath,
        status: UploadProcessingStatus.processing,
      ));
    }
  }

  Future<UploadItemDto> updateUpload({
    required String trackId,
    required String title,
    required String description,
    required String privacy,
    String? localArtworkPath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final existing = GlobalTrackStore.instance.find(trackId);
    if (existing == null) throw Exception('Track not found: $trackId');

    final updated = existing.copyWith(
      title: title,
      description: description,
      visibility:
          privacy == 'public' ? UploadVisibility.public : UploadVisibility.private,
      localArtworkPath: localArtworkPath ?? existing.localArtworkPath,
    );
    GlobalTrackStore.instance.update(updated);

    return UploadItemDto(
      id: updated.id,
      title: updated.title,
      artists: updated.artistDisplay.split(', '),
      durationSeconds: updated.durationSeconds,
      artworkUrl: updated.artworkUrl,
      localArtworkPath: updated.localArtworkPath,
      localFilePath: updated.localFilePath,
      description: updated.description,
      privacy: privacy,
      status: 'finished',
      contentWarning: updated.isExplicit,
      createdAt: updated.createdAt.toIso8601String(),
    );
  }

  String _statusString(UploadProcessingStatus s) {
    switch (s) {
      case UploadProcessingStatus.finished:
        return 'finished';
      case UploadProcessingStatus.processing:
        return 'processing';
      case UploadProcessingStatus.failed:
        return 'failed';
      case UploadProcessingStatus.deleted:
        return 'deleted';
    }
  }
}
