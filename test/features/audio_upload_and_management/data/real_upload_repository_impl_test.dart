import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/data/api/upload_api.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/create_track_request_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/finalize_track_metadata_request_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/track_response_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/upload_quota_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/real_upload_repository_impl.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_cancellation_token.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/uploaded_track.dart';

import '../helpers/upload_test_data.dart';

class FakeUploadApi extends UploadApi {
  FakeUploadApi() : super(Dio());

  UploadQuotaDto quotaResponse =
      UploadQuotaDto.fromJson(sampleUploadQuotaJson());

  TrackResponseDto createTrackResponse =
      TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'idle'));

  TrackResponseDto uploadAudioResponse =
      TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'uploading'));

  TrackResponseDto finalizeMetadataResponse =
      TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'processing'));

  TrackResponseDto trackStatusResponse =
      TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'finished'));

  TrackResponseDto trackDetailsResponse =
      TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'finished'));

  TrackResponseDto updateTrackMetadataResponse =
      TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'finished'));

  CreateTrackRequestDto? capturedCreateRequest;
  FinalizeTrackMetadataRequestDto? capturedFinalizeRequest;
  FinalizeTrackMetadataRequestDto? capturedUpdateRequest;
  int getTrackStatusCalls = 0;

  @override
  Future<UploadQuotaDto> getUploadQuota(String userId) async {
    return quotaResponse;
  }

  @override
  Future<TrackResponseDto> createTrack(CreateTrackRequestDto request) async {
    capturedCreateRequest = request;
    return createTrackResponse;
  }

  @override
  Future<TrackResponseDto> uploadAudio({
    required String trackId,
    required String filePath,
    required String fileName,
    required ProgressCallback onSendProgress,
    UploadCancellationToken? cancellationToken,
  }) async {
    onSendProgress(50, 100);
    return uploadAudioResponse;
  }

  @override
  Future<TrackResponseDto> finalizeMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) async {
    capturedFinalizeRequest = request;
    return finalizeMetadataResponse;
  }

  @override
  Future<TrackResponseDto> getTrackStatus(String trackId) async {
    getTrackStatusCalls++;
    return trackStatusResponse;
  }

  @override
  Future<TrackResponseDto> getTrackDetails(String trackId) async {
    return trackDetailsResponse;
  }

  @override
  Future<TrackResponseDto> updateTrackMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) async {
    capturedUpdateRequest = request;
    return updateTrackMetadataResponse;
  }

  @override
  Future<void> deleteTrack(String trackId) async {}
}

void main() {
  late FakeUploadApi fakeApi;
  late RealUploadRepository repository;

  setUp(() {
    fakeApi = FakeUploadApi();
    repository = RealUploadRepository(fakeApi);
  });

  group('getUploadQuota', () {
    test('maps the dto to the domain entity', () async {
      fakeApi.quotaResponse = UploadQuotaDto.fromJson(sampleUploadQuotaJson());

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
      fakeApi.createTrackResponse =
          TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'idle'));

      final result = await repository.createTrack('user-1');

      expect(fakeApi.capturedCreateRequest, isNotNull);
      expect(fakeApi.capturedCreateRequest!.userId, 'user-1');
      expect(result.status, UploadStatus.idle);
    });
  });

  group('uploadAudio', () {
    test('maps uploaded track and forwards progress callback', () async {
      fakeApi.uploadAudioResponse =
          TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'uploading'));

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
      fakeApi.finalizeMetadataResponse =
          TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'processing'));

      final result = await repository.finalizeMetadata(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      );

      expect(fakeApi.capturedFinalizeRequest, isNotNull);
      expect(fakeApi.capturedFinalizeRequest!.trackId, 'track-1');
      expect(fakeApi.capturedFinalizeRequest!.title, 'Midnight Echo');
      expect(result.status, UploadStatus.processing);
    });
  });

  group('waitUntilProcessed', () {
    test('returns once the backend reports finished', () async {
      fakeApi.trackStatusResponse =
          TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'finished'));

      final result = await repository.waitUntilProcessed('track-1');

      expect(result.status, UploadStatus.finished);
      expect(fakeApi.getTrackStatusCalls, 1);
    });

    test('returns the last known status when the backend stays processing', () {
      fakeApi.trackStatusResponse =
          TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'processing'));

      fakeAsync((async) {
        UploadedTrack? result;

        repository.waitUntilProcessed('track-1').then((value) {
          result = value;
        });

        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 5, seconds: 1));
        async.flushMicrotasks();

        expect(result, isNotNull);
        expect(result!.status, UploadStatus.processing);
        expect(fakeApi.getTrackStatusCalls, greaterThanOrEqualTo(61));
      });
    });
  });

  group('getTrackDetails', () {
    test('maps track details', () async {
      fakeApi.trackDetailsResponse =
          TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'finished'));

      final result = await repository.getTrackDetails('track-1');

      expect(result.title, 'Midnight Echo');
      expect(result.status, UploadStatus.finished);
    });
  });

  group('updateTrackMetadata', () {
    test('creates a metadata dto and maps the updated result', () async {
      fakeApi.updateTrackMetadataResponse =
          TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'finished'));

      final result = await repository.updateTrackMetadata(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      );

      expect(fakeApi.capturedUpdateRequest, isNotNull);
      expect(fakeApi.capturedUpdateRequest!.trackId, 'track-1');
      expect(result.status, UploadStatus.finished);
    });
  });

  group('deleteTrack', () {
    test('delegates deletion to the api', () async {
      await repository.deleteTrack('track-1');
    });
  });
}