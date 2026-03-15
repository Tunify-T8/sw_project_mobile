import '../dto/artist_tools_quota_dto.dart';
import '../dto/upload_item_dto.dart';

class MockLibraryUploadsApi {
  MockLibraryUploadsApi();

  final List<UploadItemDto> _uploads = [
    UploadItemDto(
      id: 'track_1',
      title: 'New Recording 109.m4a',
      artists: const ['Rozana Ahmed', 'joe'],
      durationSeconds: 229,
      artworkUrl: null,
      privacy: 'public',
      status: 'finished',
      contentWarning: false,
      createdAt: '2026-03-01T10:00:00Z',
    ),
    UploadItemDto(
      id: 'track_2',
      title: 'New Recording 109.m4a',
      artists: const ['Rozana Ahmed'],
      durationSeconds: 229,
      artworkUrl: null,
      privacy: 'private',
      status: 'finished',
      contentWarning: false,
      createdAt: '2026-03-02T10:00:00Z',
    ),
    UploadItemDto(
      id: 'track_3',
      title: 'New Recording 114.m4a',
      artists: const ['Rozana Ahmed'],
      durationSeconds: 2,
      artworkUrl: null,
      privacy: 'private',
      status: 'finished',
      contentWarning: false,
      createdAt: '2026-03-03T10:00:00Z',
    ),
  ];

  Future<List<UploadItemDto>> getMyUploads() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List<UploadItemDto>.from(_uploads);
  }

  Future<ArtistToolsQuotaDto> getArtistToolsQuota() async {
    await Future.delayed(const Duration(milliseconds: 250));

    return const ArtistToolsQuotaDto(
      tier: 'free',
      uploadMinutesLimit: 180,
      uploadMinutesUsed: 8,
      canReplaceFiles: false,
      canUpgrade: true,
    );
  }

  Future<void> deleteUpload(String trackId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _uploads.removeWhere((item) => item.id == trackId);
  }

  Future<void> replaceUploadFile({
    required String trackId,
    required String filePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _uploads.indexWhere((item) => item.id == trackId);
    if (index == -1) {
      throw Exception('Track not found');
    }

    _uploads[index] = _uploads[index].copyWith(
      status: 'processing',
    );
  }
}