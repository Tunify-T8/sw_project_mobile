// Upload Feature Guide:
// Purpose: Shared helper used across multiple upload subflows.
// Used by: library_uploads_api, mock_library_uploads_api, upload_api, and 11 more upload files.
// Concerns: Multi-format support.
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class UploadFlowException implements Exception {
  const UploadFlowException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class UploadCancelledException implements Exception {
  const UploadCancelledException();
}

String userFriendlyUploadError(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is UploadFlowException) return error.message;
  if (error is DioException) return _dioMessage(error, fallback);
  if (error is TimeoutException) {
    return 'This is taking longer than expected. Please try again.';
  }
  if (error is SocketException) {
    return 'No internet connection. Check your connection and try again.';
  }
  if (error is FileSystemException) {
    return 'We could not access that file. Please choose it again.';
  }
  if (error is FormatException) {
    return 'We received an unexpected response. Please try again.';
  }
  if (error is StateError) {
    return _stateMessage(error, fallback);
  }
  return fallback;
}

void logUploadError(String context, Object error, [StackTrace? stackTrace]) {
  debugPrint('Upload module error [$context]: $error');
  if (stackTrace != null) debugPrint('$stackTrace');
}

String _dioMessage(DioException error, String fallback) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return 'The request timed out. Please try again.';
  }
  if (error.type == DioExceptionType.connectionError) {
    return 'No internet connection. Check your connection and try again.';
  }

  final statusCode = error.response?.statusCode;
  if (statusCode == 401 || statusCode == 403) {
    return 'Your session expired. Please sign in again and try once more.';
  }
  if (statusCode == 404) {
    return 'We could not find that track anymore. Please refresh and try again.';
  }
  if (statusCode == 408) {
    return 'The request timed out. Please try again.';
  }
  if (statusCode == 409) {
    return 'That track was changed somewhere else. Please refresh and try again.';
  }
  if (statusCode == 413) {
    return 'That file is too large to upload. Please choose a smaller file.';
  }
  if (statusCode == 429) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  if (statusCode != null && statusCode >= 500) {
    return 'The upload service is having trouble right now. Please try again soon.';
  }
  return fallback;
}

String _stateMessage(StateError error, String fallback) {
  final message = error.message.toString().toLowerCase();

  if (message.contains('track not found') ||
      message.contains('track draft not found')) {
    return 'We could not find that track anymore. Please refresh and try again.';
  }
  if (message.contains('audio must be uploaded')) {
    return 'Finish uploading the audio file before saving track details.';
  }
  if (message.contains('cloudinary failed to delete')) {
    return 'We could not remove the cloud files right now. Please try again.';
  }
  if (message.contains('cloudinary is not configured')) {
    return 'Uploads are not available right now. Please try again later.';
  }
  return fallback;
}
