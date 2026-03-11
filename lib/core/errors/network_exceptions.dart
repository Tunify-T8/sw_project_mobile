import 'package:dio/dio.dart';
import 'failure.dart';

/// Maps [DioException] instances into domain-layer [Failure] objects.
///
/// Centralizing this mapping keeps all Dio-specific error handling
/// contained within the data layer. Use cases and the presentation
/// layer only ever deal with [Failure] subclasses, never with [DioException].
class NetworkExceptions {
  /// Private constructor — this class is not meant to be instantiated.
  /// Use [fromDioException] directly as a static utility.
  NetworkExceptions._();

  /// Converts a [DioException] into the appropriate [Failure] subclass.
  ///
  /// Inspects [DioException.type] to determine the category of failure:
  /// - Timeout or connection errors → [NetworkFailure]
  /// - Bad HTTP response → delegates to [_fromStatusCode]
  /// - Anything else → [UnknownFailure]
  static Failure fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        return _fromStatusCode(exception.response?.statusCode);

      default:
        return const UnknownFailure();
    }
  }

  /// Maps an HTTP [statusCode] to the appropriate [Failure].
  ///
  /// Handles the following codes explicitly:
  /// - `400` → [ValidationFailure] (bad request / invalid input)
  /// - `401` → [UnauthorizedFailure] (invalid credentials)
  /// - `409` → [ConflictFailure] (e.g. email already registered)
  /// - `500` and above → [ServerFailure]
  /// - `null` or any other code → [UnknownFailure]
  ///
  /// The [statusCode] parameter is nullable because [Response.statusCode]
  /// may be null when Dio cannot complete the request. A null code
  /// is treated as an unknown failure.
  static Failure _fromStatusCode(int? statusCode) {
    if (statusCode == null) return const UnknownFailure();

    if (statusCode >= 500) return const ServerFailure();

    switch (statusCode) {
      case 400:
        return const ValidationFailure(
          'Invalid request. Please check your input.',
        );
      case 401:
        return const UnauthorizedFailure();
      case 409:
        return const ConflictFailure(
          'An account with this email already exists.',
        );
      default:
        return const UnknownFailure();
    }
  }
}
