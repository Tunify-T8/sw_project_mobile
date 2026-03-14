import 'package:dio/dio.dart';
import 'failure.dart';

/// Maps [DioException]s to domain [Failure] types.
class NetworkExceptions {
  NetworkExceptions._();

  /// Converts a [DioException] into the appropriate [Failure] subclass.
  static Failure fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _fromStatusCode(e.response?.statusCode, e.response?.data);
      default:
        return const UnknownFailure();
    }
  }

  static Failure _fromStatusCode(int? statusCode, dynamic data) {
    if (statusCode == null) return const UnknownFailure();
    if (statusCode >= 500) return const ServerFailure();

    final message = _extractMessage(data);

    switch (statusCode) {
      case 400:
        return ValidationFailure(message ?? 'Invalid request.');
      case 401:
        return const UnauthorizedFailure();
      case 403:
        return ForbiddenFailure(message ?? 'Access denied.');
      case 404:
        return NotFoundFailure(message ?? 'Not found.');
      case 409:
        return ConflictFailure(message ?? 'Conflict.');
      default:
        return const UnknownFailure();
    }
  }

  /// Extracts the `message` field from the backend error response body.
  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }
}
