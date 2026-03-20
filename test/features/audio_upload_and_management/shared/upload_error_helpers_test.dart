import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

void main() {
  group('userFriendlyUploadError', () {
    test('prefers upload flow exception messages', () {
      expect(
        userFriendlyUploadError(const UploadFlowException('Exact message')),
        'Exact message',
      );
    });

    test('maps dio timeout and connectivity failures', () {
      expect(
        userFriendlyUploadError(
          DioException(
            requestOptions: RequestOptions(path: '/tracks'),
            type: DioExceptionType.receiveTimeout,
          ),
        ),
        'The request timed out. Please try again.',
      );

      expect(
        userFriendlyUploadError(
          DioException(
            requestOptions: RequestOptions(path: '/tracks'),
            type: DioExceptionType.connectionError,
          ),
        ),
        'No internet connection. Check your connection and try again.',
      );
    });

    test('maps dio status codes and falls back when needed', () {
      DioException status(int code) => DioException(
        requestOptions: RequestOptions(path: '/tracks'),
        response: Response(
          requestOptions: RequestOptions(path: '/tracks'),
          statusCode: code,
        ),
      );

      expect(
        userFriendlyUploadError(status(401)),
        'Your session expired. Please sign in again and try once more.',
      );
      expect(
        userFriendlyUploadError(status(404)),
        'We could not find that track anymore. Please refresh and try again.',
      );
      expect(
        userFriendlyUploadError(status(413)),
        'That file is too large to upload. Please choose a smaller file.',
      );
      expect(
        userFriendlyUploadError(status(429)),
        'Too many attempts. Please wait a moment and try again.',
      );
      expect(
        userFriendlyUploadError(status(503)),
        'The upload service is having trouble right now. Please try again soon.',
      );
      expect(
        userFriendlyUploadError(status(418), fallback: 'Fallback'),
        'Fallback',
      );
    });

    test('maps common non-network exceptions', () {
      expect(
        userFriendlyUploadError(TimeoutException('late')),
        'This is taking longer than expected. Please try again.',
      );
      expect(
        userFriendlyUploadError(const SocketException('offline')),
        'No internet connection. Check your connection and try again.',
      );
      expect(
        userFriendlyUploadError(const FileSystemException('bad file')),
        'We could not access that file. Please choose it again.',
      );
      expect(
        userFriendlyUploadError(const FormatException('bad payload')),
        'We received an unexpected response. Please try again.',
      );
    });

    test('maps state errors for known upload scenarios', () {
      expect(
        userFriendlyUploadError(StateError('Track not found')),
        'We could not find that track anymore. Please refresh and try again.',
      );
      expect(
        userFriendlyUploadError(StateError('Audio must be uploaded first')),
        'Finish uploading the audio file before saving track details.',
      );
      expect(
        userFriendlyUploadError(StateError('Cloudinary failed to delete asset')),
        'We could not remove the cloud files right now. Please try again.',
      );
      expect(
        userFriendlyUploadError(StateError('Cloudinary is not configured')),
        'Uploads are not available right now. Please try again later.',
      );
      expect(
        userFriendlyUploadError(StateError('something else'), fallback: 'Fallback'),
        'Fallback',
      );
    });
  });
}
