import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/create_track_request_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/finalize_track_metadata_request_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/track_response_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/upload_quota_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/real_upload_repository_impl.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import '../../../helpers/upload_mocks.mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
  late MockUploadApi mockApi;
  late RealUploadRepository repository;

  setUp(() {
    mockApi = MockUploadApi();
    repository = RealUploadRepository(mockApi);
  });

  group('getUploadQuota', () {
    test('maps the dto to the domain entity', () async {
      when(
        mockApi.getUploadQuota('user-1'),
      ).thenAnswer((_) async => UploadQuotaDto.fromJson(sampleUploadQuotaJson()));

      final result = await repository.getUploadQuota('user-1');

      expect(result.tier, sampleUploadQuota.tier);
      expect(result.uploadMinutesLimit, sampleUploadQuota.uploadMinutesLimit);
      expect(result.uploadMinutesUsed, sampleUploadQuota.uploadMinutesUsed);
      expect(
        result.uploadMinutesRemaining,
        sampleUploadQuota.uploadMinutesRemaining,
      );
    });
  });

  group('createTrack', () {
    test('creates a draft track', () async {
      when(
        mockApi.createTrack(any),
      ).thenAnswer((_) async => TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'idle')));

      final result = await repository.createTrack('user-1');

      final request =
          verify(mockApi.createTrack(captureAny)).captured.single
              as CreateTrackRequestDto;
      expect(request.userId, 'user-1');
      expect(result.status, UploadStatus.idle);
    });
  });

  group('uploadAudio', () {
    test('maps uploaded track and forwards progress callback', () async {
      when(
        mockApi.uploadAudio(
          trackId: 'track-1',
          filePath: samplePickedUploadFile.path,
          fileName: samplePickedUploadFile.name,
          cancellationToken: anyNamed('cancellationToken'),
          onSendProgress: anyNamed('onSendProgress'),
        ),
      ).thenAnswer((invocation) async {
        final onSendProgress =
            invocation.namedArguments[#onSendProgress]
                as void Function(int, int);
        onSendProgress(50, 100);
        return TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'uploading'));
      });

      final progress = <double>[];
      final result = await repository.uploadAudio(
        trackId: 'track-1',
        file: samplePickedUploadFile,
        onProgress: progress.add,
      );

      expect(result.status, UploadStatus.uploading);
      expect(progress, [0.5]);
    });
  });

  group('finalizeMetadata', () {
    test('creates a metadata dto and maps the result', () async {
      when(
        mockApi.finalizeMetadata(any),
      ).thenAnswer((_) async => TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'processing')));

      final result = await repository.finalizeMetadata(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      );

      final request =
          verify(mockApi.finalizeMetadata(captureAny)).captured.single
              as FinalizeTrackMetadataRequestDto;
      expect(request.trackId, 'track-1');
      expect(request.title, 'Midnight Echo');
      expect(result.status, UploadStatus.processing);
    });
  });

  group('waitUntilProcessed', () {
    test('returns once the backend reports finished', () async {
      when(
        mockApi.getTrackStatus('track-1'),
      ).thenAnswer((_) async => TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'finished')));

      final result = await repository.waitUntilProcessed('track-1');

      expect(result.status, UploadStatus.finished);
      verify(mockApi.getTrackStatus('track-1')).called(1);
    });

    test('throws when the backend never leaves processing', () {
      when(
        mockApi.getTrackStatus('track-1'),
      ).thenAnswer((_) async => TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'processing')));

      fakeAsync((async) {
        expectLater(
          repository.waitUntilProcessed('track-1'),
          throwsA(isA<UploadFlowException>()),
        );
        async.elapse(const Duration(seconds: 60));
      });
    });
  });

  group('getTrackDetails', () {
    test('maps track details', () async {
      when(
        mockApi.getTrackDetails('track-1'),
      ).thenAnswer((_) async => TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'finished')));

      final result = await repository.getTrackDetails('track-1');

      expect(result.title, 'Midnight Echo');
      expect(result.status, UploadStatus.finished);
    });
  });

  group('updateTrackMetadata', () {
    test('creates a metadata dto and maps the updated result', () async {
      when(
        mockApi.updateTrackMetadata(any),
      ).thenAnswer((_) async => TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'finished')));

      final result = await repository.updateTrackMetadata(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      );

      final request =
          verify(mockApi.updateTrackMetadata(captureAny)).captured.single
              as FinalizeTrackMetadataRequestDto;
      expect(request.trackId, 'track-1');
      expect(result.status, UploadStatus.finished);
    });
  });

  group('deleteTrack', () {
    test('delegates deletion to the api', () async {
      when(mockApi.deleteTrack('track-1')).thenAnswer((_) async {});

      await repository.deleteTrack('track-1');

      verify(mockApi.deleteTrack('track-1')).called(1);
      verifyNoMoreInteractions(mockApi);
    });
  });
}
