import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/core/errors/network_exceptions.dart';

/// Unit tests for [NetworkExceptions.fromDioException].
///
/// No mocks needed — the function is a pure mapping from DioException → Failure.
void main() {
  // Helper to build a DioException cleanly in every test.
  DioException make(DioExceptionType type, {int? statusCode}) {
    return DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: type,
      response: statusCode != null
          ? Response(
              requestOptions: RequestOptions(path: '/test'),
              statusCode: statusCode,
            )
          : null,
    );
  }

  group('NetworkExceptions.fromDioException', () {
    // ── Timeout / connectivity errors ────────────────────────────────────────

    test('connection timeout → NetworkFailure', () {
      expect(
        NetworkExceptions.fromDioException(
          make(DioExceptionType.connectionTimeout),
        ),
        isA<NetworkFailure>(),
      );
    });

    test('receive timeout → NetworkFailure', () {
      expect(
        NetworkExceptions.fromDioException(
          make(DioExceptionType.receiveTimeout),
        ),
        isA<NetworkFailure>(),
      );
    });

    test('send timeout → NetworkFailure', () {
      expect(
        NetworkExceptions.fromDioException(make(DioExceptionType.sendTimeout)),
        isA<NetworkFailure>(),
      );
    });

    test('connection error (no internet) → NetworkFailure', () {
      expect(
        NetworkExceptions.fromDioException(
          make(DioExceptionType.connectionError),
        ),
        isA<NetworkFailure>(),
      );
    });

    // ── 4xx client errors ────────────────────────────────────────────────────

    test('400 → ValidationFailure', () {
      expect(
        NetworkExceptions.fromDioException(
          make(DioExceptionType.badResponse, statusCode: 400),
        ),
        isA<ValidationFailure>(),
      );
    });

    test('401 → UnauthorizedFailure', () {
      expect(
        NetworkExceptions.fromDioException(
          make(DioExceptionType.badResponse, statusCode: 401),
        ),
        isA<UnauthorizedFailure>(),
      );
    });

    test('403 → ForbiddenFailure', () {
      expect(
        NetworkExceptions.fromDioException(
          make(DioExceptionType.badResponse, statusCode: 403),
        ),
        isA<ForbiddenFailure>(),
      );
    });

    test('404 → NotFoundFailure', () {
      expect(
        NetworkExceptions.fromDioException(
          make(DioExceptionType.badResponse, statusCode: 404),
        ),
        isA<NotFoundFailure>(),
      );
    });

    test('409 → ConflictFailure', () {
      expect(
        NetworkExceptions.fromDioException(
          make(DioExceptionType.badResponse, statusCode: 409),
        ),
        isA<ConflictFailure>(),
      );
    });

    // ── 5xx server errors ────────────────────────────────────────────────────

    test('500 → ServerFailure', () {
      expect(
        NetworkExceptions.fromDioException(
          make(DioExceptionType.badResponse, statusCode: 500),
        ),
        isA<ServerFailure>(),
      );
    });

    test('503 → ServerFailure', () {
      expect(
        NetworkExceptions.fromDioException(
          make(DioExceptionType.badResponse, statusCode: 503),
        ),
        isA<ServerFailure>(),
      );
    });

    // ── Edge cases ───────────────────────────────────────────────────────────

    test('badResponse with null status code → UnknownFailure', () {
      expect(
        NetworkExceptions.fromDioException(
          make(DioExceptionType.badResponse, statusCode: null),
        ),
        isA<UnknownFailure>(),
      );
    });

    test('unknown DioExceptionType → UnknownFailure', () {
      expect(
        NetworkExceptions.fromDioException(make(DioExceptionType.unknown)),
        isA<UnknownFailure>(),
      );
    });

    test('cancel type → UnknownFailure', () {
      expect(
        NetworkExceptions.fromDioException(make(DioExceptionType.cancel)),
        isA<UnknownFailure>(),
      );
    });
  });
}
