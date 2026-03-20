import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/network/api_endpoints.dart';
import 'package:software_project/features/audio_upload_and_management/data/api/library_uploads_api.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import '../../../../helpers/upload_mocks.mocks.dart';
import '../../helpers/upload_test_data.dart';

void main() {
  late MockDio mockDio;
  late LibraryUploadsApi api;

  setUp(() {
    mockDio = MockDio();
    api = LibraryUploadsApi(mockDio);
  });

  Response<dynamic> okResponse(dynamic data) => Response(
    data: data,
    requestOptions: RequestOptions(path: '/test'),
    statusCode: 200,
  );

  group('getMyUploads', () {
    test('parses a bare list response', () async {
      when(
        mockDio.get(ApiEndpoints.myUploads),
      ).thenAnswer((_) async => okResponse([sampleUploadItemJson()]));

      final result = await api.getMyUploads();

      expect(result.single.id, 'track-1');
      verify(mockDio.get(ApiEndpoints.myUploads)).called(1);
    });

    test('parses uploads nested under data', () async {
      when(
        mockDio.get(ApiEndpoints.myUploads),
      ).thenAnswer((_) async => okResponse({'data': [sampleUploadItemJson()]}));

      final result = await api.getMyUploads();

      expect(result.single.title, 'Midnight Echo');
    });

    test('returns empty when payload shape is not supported', () async {
      when(
        mockDio.get(ApiEndpoints.myUploads),
      ).thenAnswer((_) async => okResponse('unexpected'));

      final result = await api.getMyUploads();

      expect(result, isEmpty);
    });
  });

  group('getArtistToolsQuota', () {
    test('parses a flat payload', () async {
      when(
        mockDio.get(ApiEndpoints.artistToolsQuota()),
      ).thenAnswer((_) async => okResponse(sampleArtistToolsQuotaJson()));

      final result = await api.getArtistToolsQuota();

      expect(result.tier, 'free');
      expect(result.canUpgrade, isTrue);
    });

    test('parses a nested data payload', () async {
      when(
        mockDio.get(ApiEndpoints.artistToolsQuota()),
      ).thenAnswer((_) async => okResponse({'data': sampleArtistToolsQuotaJson()}));

      final result = await api.getArtistToolsQuota();

      expect(result.uploadMinutesUsed, 12);
    });

    test('throws UploadFlowException when payload is invalid', () {
      when(
        mockDio.get(ApiEndpoints.artistToolsQuota()),
      ).thenAnswer((_) async => okResponse('bad'));

      expect(api.getArtistToolsQuota(), throwsA(isA<UploadFlowException>()));
    });
  });

  group('deleteUpload', () {
    test('calls the delete endpoint', () async {
      when(
        mockDio.delete(ApiEndpoints.deleteUpload('track-1')),
      ).thenAnswer((_) async => okResponse({}));

      await api.deleteUpload('track-1');

      verify(mockDio.delete(ApiEndpoints.deleteUpload('track-1'))).called(1);
    });
  });

  group('replaceUploadFile', () {
    test('posts a replacement audio file', () async {
      final directory = await Directory.systemTemp.createTemp('library_replace_api');
      addTearDown(() => directory.delete(recursive: true));
      final audioFile = File('${directory.path}/replacement.mp3');
      await audioFile.writeAsString('audio');

      when(
        mockDio.post(
          ApiEndpoints.replaceUploadFile('track-1'),
          data: anyNamed('data'),
        ),
      ).thenAnswer((_) async => okResponse({}));

      await api.replaceUploadFile(trackId: 'track-1', filePath: audioFile.path);

      verify(
        mockDio.post(
          ApiEndpoints.replaceUploadFile('track-1'),
          data: anyNamed('data'),
        ),
      ).called(1);
    });
  });

  group('updateUpload', () {
    test('patches metadata without artwork', () async {
      when(
        mockDio.patch(
          ApiEndpoints.updateTrack('track-1'),
          data: {
            'title': 'Updated',
            'description': 'Updated description',
            'privacy': 'private',
          },
        ),
      ).thenAnswer((_) async => okResponse(sampleUploadItemJson(privacy: 'private')));

      final result = await api.updateUpload(
        trackId: 'track-1',
        title: 'Updated',
        description: 'Updated description',
        privacy: 'private',
      );

      expect(result.privacy, 'private');
    });

    test('patches metadata with artwork file', () async {
      final directory = await Directory.systemTemp.createTemp('library_update_api');
      addTearDown(() => directory.delete(recursive: true));
      final artwork = File('${directory.path}/cover.png');
      await artwork.writeAsString('image');

      when(
        mockDio.patch(
          ApiEndpoints.updateTrack('track-1'),
          data: anyNamed('data'),
        ),
      ).thenAnswer((_) async => okResponse({'data': sampleUploadItemJson()}));

      final result = await api.updateUpload(
        trackId: 'track-1',
        title: 'Updated',
        description: 'Updated description',
        privacy: 'public',
        localArtworkPath: artwork.path,
      );

      expect(result.title, 'Midnight Echo');
      verify(
        mockDio.patch(
          ApiEndpoints.updateTrack('track-1'),
          data: anyNamed('data'),
        ),
      ).called(1);
    });

    test('throws UploadFlowException when the response is not a map', () {
      when(
        mockDio.patch(
          ApiEndpoints.updateTrack('track-1'),
          data: {
            'title': 'Updated',
            'description': 'Updated description',
            'privacy': 'private',
          },
        ),
      ).thenAnswer((_) async => okResponse('bad'));

      expect(
        api.updateUpload(
          trackId: 'track-1',
          title: 'Updated',
          description: 'Updated description',
          privacy: 'private',
        ),
        throwsA(isA<UploadFlowException>()),
      );
    });
  });
}
