import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/shared/ui/patterns/error_ui_mapper.dart';

void main() {
  DioException _dio(
    DioExceptionType type, {
    int? statusCode,
    dynamic data,
  }) {
    final options = RequestOptions(path: '/test');
    return DioException(
      requestOptions: options,
      type: type,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: options,
              statusCode: statusCode,
              data: data,
            ),
    );
  }

  group('mapToUiErrorState', () {
    test('connection error -> retryable fetch message', () {
      final state = mapToUiErrorState(_dio(DioExceptionType.connectionError));

      expect(state.retryable, isTrue);
      expect(
        state.message,
        'Could not fetch data. Please check your internet and try again.',
      );
    });

    test('server error 500 -> retryable fetch message', () {
      final state = mapToUiErrorState(
        _dio(DioExceptionType.badResponse, statusCode: 500),
      );

      expect(state.retryable, isTrue);
      expect(
        state.message,
        'Could not fetch data. Please check your internet and try again.',
      );
    });

    test('forbidden 403 -> non-retryable permissible message', () {
      final state = mapToUiErrorState(
        _dio(DioExceptionType.badResponse, statusCode: 403),
      );

      expect(state.retryable, isFalse);
      expect(state.message, 'Action not permissible.');
    });

    test('bad request 400 -> non-retryable permissible message', () {
      final state = mapToUiErrorState(
        _dio(DioExceptionType.badResponse, statusCode: 400),
      );

      expect(state.retryable, isFalse);
      expect(state.message, 'Action not permissible.');
    });

    test('plain timeout text error -> retryable', () {
      final state = mapToUiErrorState(Exception('socket timeout while fetch'));

      expect(state.retryable, isTrue);
      expect(
        state.message,
        'Could not fetch data. Please check your internet and try again.',
      );
    });

    test('plain forbidden text error -> non-retryable', () {
      final state = mapToUiErrorState(Exception('forbidden'));

      expect(state.retryable, isFalse);
      expect(state.message, 'Action not permissible.');
    });
  });
}
