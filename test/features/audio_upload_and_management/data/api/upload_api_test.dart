import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/network/api_endpoints.dart';
import 'package:software_project/features/audio_upload_and_management/data/api/upload_api.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/create_track_request_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/finalize_track_metadata_request_dto.dart';

import '../../../../helpers/upload_mocks.mocks.dart';
import '../../helpers/upload_test_data.dart';

void main() {
  late MockDio mockDio;
  late UploadApi api;

  setUp(() {
    mockDio = MockDio();
    api = UploadApi(mockDio);
  });

  Response<dynamic> okResponse(Map<String, dynamic> data) => Response(
    data: data,
    requestOptions: RequestOptions(path: '/test'),
    statusCode: 200,
  );

  group('getUploadQuota', () {
    test('calls the quota endpoint and parses the response', () async {
      when(
        mockDio.get(ApiEndpoints.uploadQuota()),
      ).thenAnswer((_) async => okResponse(sampleUploadQuotaJson()));

      final result = await api.getUploadQuota('user-1');

      expect(result.tier, 'free');
      expect(result.uploadMinutesRemaining, 168);
      verify(mockDio.get(ApiEndpoints.uploadQuota())).called(1);
    });
  });

  group('createTrack', () {
    test('posts the create track payload and parses the response', () async {
      final request = CreateTrackRequestDto(userId: 'user-1');
      when(
        mockDio.post(ApiEndpoints.createTrack(), data: request.toJson()),
      ).thenAnswer((_) async => okResponse(sampleTrackResponseJson(status: 'idle')));

      final result = await api.createTrack(request);

      expect(result.trackId, 'track-1');
      expect(result.status, 'idle');
      verify(mockDio.post(ApiEndpoints.createTrack(), data: request.toJson())).called(1);
    });
  });

  group('uploadAudio', () {
    test('uploads multipart audio and parses the response', () async {
      final directory = await Directory.systemTemp.createTemp('upload_api_audio');
      addTearDown(() => directory.delete(recursive: true));
      final audioFile = File('${directory.path}/track.mp3');
      await audioFile.writeAsString('audio');

      when(
        mockDio.post(
          ApiEndpoints.uploadAudio('track-1'),
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
          options: anyNamed('options'),
          onSendProgress: anyNamed('onSendProgress'),
        ),
      ).thenAnswer((_) async => okResponse(sampleTrackResponseJson(status: 'uploading')));

      final progress = <List<int>>[];
      final result = await api.uploadAudio(
        trackId: 'track-1',
        filePath: audioFile.path,
        fileName: 'track.mp3',
        onSendProgress: (sent, total) => progress.add([sent, total]),
      );

      expect(result.status, 'uploading');
      verify(
        mockDio.post(
          ApiEndpoints.uploadAudio('track-1'),
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
          options: anyNamed('options'),
          onSendProgress: anyNamed('onSendProgress'),
        ),
      ).called(1);
    });
  });

  group('replaceAudio', () {
    test('uploads replacement multipart audio and parses the response', () async {
      final directory = await Directory.systemTemp.createTemp('replace_api_audio');
      addTearDown(() => directory.delete(recursive: true));
      final audioFile = File('${directory.path}/replacement.mp3');
      await audioFile.writeAsString('audio');

      when(
        mockDio.post(
          ApiEndpoints.replaceAudio('track-1'),
          data: anyNamed('data'),
          options: anyNamed('options'),
          onSendProgress: anyNamed('onSendProgress'),
        ),
      ).thenAnswer((_) async => okResponse(sampleTrackResponseJson(status: 'processing')));

      final result = await api.replaceAudio(
        trackId: 'track-1',
        filePath: audioFile.path,
        fileName: 'replacement.mp3',
        onSendProgress: (_, __) {},
      );

      expect(result.status, 'processing');
      verify(
        mockDio.post(
          ApiEndpoints.replaceAudio('track-1'),
          data: anyNamed('data'),
          options: anyNamed('options'),
          onSendProgress: anyNamed('onSendProgress'),
        ),
      ).called(1);
    });
  });

  group('finalizeMetadata', () {
    test('puts multipart metadata and parses the response', () async {
      final request = FinalizeTrackMetadataRequestDto.fromEntity(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      );

      when(
        mockDio.put(
          ApiEndpoints.finalizeMetadata('track-1'),
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer((_) async => okResponse(sampleTrackResponseJson(status: 'processing')));

      final result = await api.finalizeMetadata(request);

      expect(result.status, 'processing');
      verify(
        mockDio.put(
          ApiEndpoints.finalizeMetadata('track-1'),
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).called(1);
    });
  });

  group('getTrackStatus', () {
    test('gets the current track status', () async {
      when(
        mockDio.get(ApiEndpoints.trackStatus('track-1')),
      ).thenAnswer((_) async => okResponse(sampleTrackResponseJson(status: 'finished')));

      final result = await api.getTrackStatus('track-1');

      expect(result.status, 'finished');
      verify(mockDio.get(ApiEndpoints.trackStatus('track-1'))).called(1);
    });
  });

  group('getTrackDetails', () {
    test('gets track details', () async {
      when(
        mockDio.get(ApiEndpoints.trackDetails('track-1')),
      ).thenAnswer((_) async => okResponse(sampleTrackResponseJson(status: 'finished')));

      final result = await api.getTrackDetails('track-1');

      expect(result.title, 'Midnight Echo');
      verify(mockDio.get(ApiEndpoints.trackDetails('track-1'))).called(1);
    });
  });

  group('updateTrackMetadata', () {
    test('patches multipart metadata and parses the response', () async {
      final request = FinalizeTrackMetadataRequestDto.fromEntity(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      );

      when(
        mockDio.patch(
          ApiEndpoints.updateTrack('track-1'),
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer((_) async => okResponse(sampleTrackResponseJson(status: 'finished')));

      final result = await api.updateTrackMetadata(request);

      expect(result.status, 'finished');
      verify(
        mockDio.patch(
          ApiEndpoints.updateTrack('track-1'),
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).called(1);
    });
  });

  group('deleteTrack', () {
    test('deletes the track', () async {
      when(
        mockDio.delete(ApiEndpoints.deleteTrack('track-1')),
      ).thenAnswer((_) async => okResponse({'status': 'deleted'}));

      await api.deleteTrack('track-1');

      verify(mockDio.delete(ApiEndpoints.deleteTrack('track-1'))).called(1);
    });
  });
}
