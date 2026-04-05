import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/artist_tools_quota_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/upload_item_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/library_uploads_repository_impl.dart';

import '../helpers/local_upload_test_mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
  late MockLibraryUploadsApi mockApi;
  late MockMockLibraryUploadsApi mockMockApi;

  setUp(() {
    mockApi = MockLibraryUploadsApi();
    mockMockApi = MockMockLibraryUploadsApi();
  });

  group('getMyUploads', () {
    test('uses the mock api when useMock=true', () async {
      final repository = LibraryUploadsRepositoryImpl(
        api: mockApi,
        mockApi: mockMockApi,
        useMock: true,
      );

      when(
        mockMockApi.getMyUploads(),
      ).thenAnswer((_) async => [UploadItemDto.fromJson(sampleUploadItemJson())]);

      final result = await repository.getMyUploads();

      expect(result.single.id, 'track-1');
      verify(mockMockApi.getMyUploads()).called(1);
      verifyNever(mockApi.getMyUploads());
    });

    test('uses the real api when useMock=false', () async {
      final repository = LibraryUploadsRepositoryImpl(
        api: mockApi,
        mockApi: mockMockApi,
        useMock: false,
      );

      when(
        mockApi.getMyUploads(),
      ).thenAnswer((_) async => [UploadItemDto.fromJson(sampleUploadItemJson())]);

      final result = await repository.getMyUploads();

      expect(result.single.title, 'Midnight Echo');
      verify(mockApi.getMyUploads()).called(1);
      verifyNever(mockMockApi.getMyUploads());
    });
  });

  group('getArtistToolsQuota', () {
    test('maps quota through the configured source', () async {
      final repository = LibraryUploadsRepositoryImpl(
        api: mockApi,
        mockApi: mockMockApi,
        useMock: false,
      );

      when(
        mockApi.getArtistToolsQuota(),
      ).thenAnswer((_) async => const ArtistToolsQuotaDto(
        tier: 'free',
        uploadMinutesLimit: 180,
        uploadMinutesUsed: 12,
        canReplaceFiles: false,
        canUpgrade: true,
      ));

      final result = await repository.getArtistToolsQuota();

      expect(result.uploadMinutesRemaining, 168);
      expect(result.canUpgrade, isTrue);
    });
  });

  group('deleteUpload', () {
    test('delegates deletion to the configured source', () async {
      final repository = LibraryUploadsRepositoryImpl(
        api: mockApi,
        mockApi: mockMockApi,
        useMock: false,
      );

      when(mockApi.deleteUpload('track-1')).thenAnswer((_) async {});

      await repository.deleteUpload('track-1');

      verify(mockApi.deleteUpload('track-1')).called(1);
    });
  });

  group('replaceUploadFile', () {
    test('delegates replacement to the configured source', () async {
      final repository = LibraryUploadsRepositoryImpl(
        api: mockApi,
        mockApi: mockMockApi,
        useMock: true,
      );

      when(
        mockMockApi.replaceUploadFile(
          trackId: 'track-1',
          filePath: '/tmp/replacement.mp3',
        ),
      ).thenAnswer((_) async {});

      await repository.replaceUploadFile(
        trackId: 'track-1',
        filePath: '/tmp/replacement.mp3',
      );

      verify(
        mockMockApi.replaceUploadFile(
          trackId: 'track-1',
          filePath: '/tmp/replacement.mp3',
        ),
      ).called(1);
    });
  });

  group('updateUpload', () {
    test('maps updated upload item from the configured source', () async {
      final repository = LibraryUploadsRepositoryImpl(
        api: mockApi,
        mockApi: mockMockApi,
        useMock: false,
      );

      when(
        mockApi.updateUpload(
          trackId: 'track-1',
          title: 'Updated',
          description: 'Updated description',
          privacy: 'private',
          localArtworkPath: '/tmp/art.png',
        ),
      ).thenAnswer(
        (_) async => UploadItemDto.fromJson(sampleUploadItemJson(privacy: 'private')),
      );

      final result = await repository.updateUpload(
        trackId: 'track-1',
        title: 'Updated',
        description: 'Updated description',
        privacy: 'private',
        localArtworkPath: '/tmp/art.png',
      );

      expect(result.visibility.name, 'private');
      verify(
        mockApi.updateUpload(
          trackId: 'track-1',
          title: 'Updated',
          description: 'Updated description',
          privacy: 'private',
          localArtworkPath: '/tmp/art.png',
        ),
      ).called(1);
    });
  });
}