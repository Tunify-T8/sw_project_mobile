import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/network/api_endpoints.dart';
import 'package:software_project/features/audio_upload_and_management/data/api/upload_api.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_cancellation_token.dart';

import '../../helpers/local_upload_test_mocks.dart';
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

  test(
    'uploadAudio cancels the internal Dio token when the external upload token is cancelled',
    () async {
      final directory = await Directory.systemTemp.createTemp('upload_api_cancel');
      addTearDown(() => directory.delete(recursive: true));

      final audioFile = File('${directory.path}/track.mp3');
      await audioFile.writeAsString('audio');

      final externalCancellationToken = UploadCancellationToken();
      CancelToken? capturedCancelToken;

      when(
        mockDio.post(
          ApiEndpoints.uploadAudio('track-1'),
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
          onSendProgress: anyNamed('onSendProgress'),
          onReceiveProgress: anyNamed('onReceiveProgress'),
        ),
      ).thenAnswer((invocation) async {
        capturedCancelToken =
            invocation.namedArguments[#cancelToken] as CancelToken?;

        externalCancellationToken.cancel();

        return okResponse(sampleTrackResponseJson(status: 'uploading'));
      });

      final result = await api.uploadAudio(
        trackId: 'track-1',
        filePath: audioFile.path,
        fileName: 'track.mp3',
        onSendProgress: (_, __) {},
        cancellationToken: externalCancellationToken,
      );

      expect(result.status, 'uploading');
      expect(externalCancellationToken.isCancelled, isTrue);
      expect(capturedCancelToken, isNotNull);
      expect(capturedCancelToken!.isCancelled, isTrue);
    },
  );
}