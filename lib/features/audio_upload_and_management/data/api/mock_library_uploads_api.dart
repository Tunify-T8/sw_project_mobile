// Upload Feature Guide:
// Purpose: Mock API for the My Uploads surface backed by the in-memory GlobalTrackStore.
// Used by: library_uploads_repository_impl, library_uploads_repository_provider
// Concerns: Multi-format support; Track visibility.
import '../dto/artist_tools_quota_dto.dart';
import '../dto/upload_item_dto.dart';
import '../../../../core/storage/token_storage.dart';
import '../services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import '../../shared/upload_error_helpers.dart';

/// Mock API for the Library / Your Uploads screen.
/// Starts EMPTY — tracks only appear after the user uploads them via the upload flow.
/// Reads/writes from GlobalTrackStore which is the single source of truth.
class MockLibraryUploadsApi {
  MockLibraryUploadsApi({TokenStorage tokenStorage = const TokenStorage()})
    : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;

  Future<List<UploadItemDto>> getMyUploads() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final user = await _tokenStorage.getUser();
    final uploads = user == null
        ? GlobalTrackStore.instance.all
        : GlobalTrackStore.instance.allForUser(user.id);

    return uploads.where((item) => !item.isDeleted).map(_toDto).toList();
  }

  Future<ArtistToolsQuotaDto> getArtistToolsQuota() async {
    await Future.delayed(const Duration(milliseconds: 150));

    final user = await _tokenStorage.getUser();
    final usedMinutes = user == null
        ? GlobalTrackStore.instance.usedUploadMinutesForAllTracks()
        : GlobalTrackStore.instance.usedUploadMinutesForUser(user.id);

    return ArtistToolsQuotaDto(
      tier: 'free',
      uploadMinutesLimit: 180,
      uploadMinutesUsed: usedMinutes,
      canReplaceFiles: false,
      //canUpgrade: true,
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
      GlobalTrackStore.instance.update(
        existing.copyWith(
          localFilePath: filePath,
          status: UploadProcessingStatus.processing,
        ),
      );
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
    if (existing == null) {
      throw const UploadFlowException(
        'We could not find that track anymore. Please refresh and try again.',
      );
    }

    final updated = existing.copyWith(
      title: title,
      description: description,
      visibility: privacy == 'public'
          ? UploadVisibility.public
          : UploadVisibility.private,
      localArtworkPath: localArtworkPath ?? existing.localArtworkPath,
      artworkUrl: localArtworkPath ?? existing.artworkUrl,
    );
    GlobalTrackStore.instance.update(updated);

    return _toDto(updated);
  }

  UploadItemDto _toDto(UploadItem item) {
    return UploadItemDto(
      id: item.id,
      title: item.title,
      artists: item.artistDisplay.split(', '),
      durationSeconds: item.durationSeconds,
      audioUrl: item.audioUrl,
      waveformUrl: item.waveformUrl,
      waveformBars: item.waveformBars,
      artworkUrl: item.artworkUrl,
      localArtworkPath: item.localArtworkPath,
      localFilePath: item.localFilePath,
      description: item.description,
      tags: item.tags,
      genreCategory: item.genreCategory,
      genreSubGenre: item.genreSubGenre,
      privacy: item.visibility == UploadVisibility.public
          ? 'public'
          : 'private',
      status: _statusString(item.status),
      contentWarning: item.isExplicit,
      recordLabel: item.recordLabel,
      publisher: item.publisher,
      isrc: item.isrc,
      pLine: item.pLine,
      scheduledReleaseDate: item.scheduledReleaseDate?.toIso8601String(),
      allowDownloads: item.allowDownloads,
      offlineListening: item.offlineListening,
      includeInRss: item.includeInRss,
      displayEmbedCode: item.displayEmbedCode,
      appPlaybackEnabled: item.appPlaybackEnabled,
      availabilityType: item.availabilityType,
      availabilityRegions: item.availabilityRegions,
      licensing: item.licensing,
      createdAt: item.createdAt.toIso8601String(),
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
