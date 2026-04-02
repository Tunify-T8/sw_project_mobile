import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/mock_upload_repository_impl.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/mock_upload_repository_mapper.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_cancellation_token.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import '../helpers/local_upload_test_mocks.dart' show MockMockUploadService;
import '../helpers/upload_test_data.dart';

void main() {
  late MockMockUploadService mockService;
  late MockUploadRepository repository;

  setUp(() {
    mockService = MockMockUploadService();
    repository = MockUploadRepository(service: mockService);
  });

  group('mock upload mapper helpers', () {
    test('buildMockTrackMetadataPayload serializes domain metadata', () {
      final payload = buildMockTrackMetadataPayload(sampleTrackMetadata);

      expect(payload['title'], 'Midnight Echo');
      expect(payload['genreCategory'], 'music');
      expect(payload['genreSubGenre'], 'hiphop');
      expect(payload['artists'], ['Kevin']);
      expect(payload['availabilityRegions'], isEmpty);
      expect(payload['pLine'], '2026 Night Records');
      expect(payload['scheduledReleaseDate'], '2026-04-01T00:00:00.000Z');
    });

    test('mapMockTrackResponse and mapMockUploadStatus map known and unknown states', () {
      final response =
          mapMockTrackResponse(sampleTrackResponseJson(status: 'finished'));

      expect(response.trackId, 'track-1');
      expect(response.status, UploadStatus.finished);
      expect(response.title, 'Midnight Echo');
      expect(mapMockUploadStatus('uploading'), UploadStatus.uploading);
      expect(mapMockUploadStatus('deleted'), UploadStatus.deleted);
      expect(mapMockUploadStatus('mystery'), UploadStatus.failed);
    });
  });

  group('MockUploadRepository', () {
    test('maps upload quota data from the service', () async {
      when(mockService.getUploadQuota(userId: 'user-1')).thenAnswer(
        (_) async => {
          'tier': 'free',
          'uploadMinutesLimit': 180,
          'uploadMinutesUsed': 12,
          'uploadMinutesRemaining': 168,
          'canReplaceFiles': false,
          'canScheduleRelease': false,
          'canAccessAdvancedTab': false,
        },
      );

      final quota = await repository.getUploadQuota('user-1');

      expect(quota.tier, 'free');
      expect(quota.uploadMinutesRemaining, 168);
    });

    test('creates tracks and uploads audio while forwarding progress', () async {
      when(mockService.createTrack(userId: 'user-1')).thenAnswer(
        (_) async => sampleTrackResponseJson(status: 'idle'),
      );
      when(mockService.uploadProgress()).thenAnswer(
        (_) => Stream<double>.fromIterable(const [0.25, 1.0]),
      );
      when(
        mockService.uploadAudio(
          trackId: 'track-1',
          localFilePath: samplePickedUploadFile.path,
        ),
      ).thenAnswer(
        (_) async => sampleTrackResponseJson(status: 'processing'),
      );

      final created = await repository.createTrack('user-1');
      final progress = <double>[];
      final uploaded = await repository.uploadAudio(
        trackId: 'track-1',
        file: samplePickedUploadFile,
        onProgress: progress.add,
      );

      expect(created.status, UploadStatus.idle);
      expect(uploaded.status, UploadStatus.processing);
      expect(progress, [0.25, 1.0]);
    });

    test('throws UploadCancelledException when cancellation is requested', () async {
      when(
        mockService.uploadProgress(),
      ).thenAnswer((_) => Stream<double>.fromIterable(const [0.5]));

      final cancellationToken = UploadCancellationToken();
      cancellationToken.cancel();

      expect(
        repository.uploadAudio(
          trackId: 'track-1',
          file: samplePickedUploadFile,
          onProgress: (_) {},
          cancellationToken: cancellationToken,
        ),
        throwsA(isA<UploadCancelledException>()),
      );
      verifyNever(
        mockService.uploadAudio(
          trackId: 'track-1',
          localFilePath: samplePickedUploadFile.path,
        ),
      );
    });

    test('finalize wait update details and delete delegate to the service', () async {
      final metadataPayload = buildMockTrackMetadataPayload(sampleTrackMetadata);

      when(
        mockService.finalizeMetadata(
          trackId: 'track-1',
          metadata: metadataPayload,
        ),
      ).thenAnswer((_) async => sampleTrackResponseJson(status: 'processing'));

      when(
        mockService.pollTrackStatus(trackId: 'track-1'),
      ).thenAnswer((_) async => sampleTrackResponseJson(status: 'finished'));

      when(
        mockService.getTrackDetails(trackId: 'track-1'),
      ).thenAnswer((_) async => sampleTrackResponseJson(status: 'finished'));

      when(
        mockService.updateTrackMetadata(
          trackId: 'track-1',
          metadata: metadataPayload,
        ),
      ).thenAnswer((_) async => sampleTrackResponseJson(status: 'finished'));

      when(mockService.deleteTrack(trackId: 'track-1')).thenAnswer((_) async {});

      final finalized = await repository.finalizeMetadata(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      );
      final processed = await repository.waitUntilProcessed('track-1');
      final details = await repository.getTrackDetails('track-1');
      final updated = await repository.updateTrackMetadata(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      );
      await repository.deleteTrack('track-1');

      expect(finalized.status, UploadStatus.processing);
      expect(processed.status, UploadStatus.finished);
      expect(details.trackId, 'track-1');
      expect(updated.status, UploadStatus.finished);

      verify(
        mockService.finalizeMetadata(
          trackId: 'track-1',
          metadata: metadataPayload,
        ),
      ).called(1);

      verify(
        mockService.updateTrackMetadata(
          trackId: 'track-1',
          metadata: metadataPayload,
        ),
      ).called(1);

      verify(mockService.deleteTrack(trackId: 'track-1')).called(1);
    });
  });
}