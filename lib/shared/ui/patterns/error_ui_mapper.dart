import 'package:dio/dio.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/network_exceptions.dart';

class UiErrorState {
  const UiErrorState({
    required this.message,
    required this.retryable,
  });

  final String message;
  final bool retryable;
}

UiErrorState mapToUiErrorState(Object error) {
  if (error is DioException) {
    final failure = NetworkExceptions.fromDioException(error);
    if (failure is NetworkFailure || failure is ServerFailure) {
      return const UiErrorState(
        message: 'Could not fetch data. Please check your internet and try again.',
        retryable: true,
      );
    }
    if (failure is ValidationFailure ||
        failure is UnauthorizedFailure ||
        failure is ForbiddenFailure ||
        failure is ConflictFailure) {
      return const UiErrorState(
        message: 'Action not permissible.',
        retryable: false,
      );
    }
    return const UiErrorState(
      message: 'Could not fetch data. Please try again.',
      retryable: true,
    );
  }

  final lowered = error.toString().toLowerCase();
  if (lowered.contains('socket') ||
      lowered.contains('timeout') ||
      lowered.contains('network') ||
      lowered.contains('fetch')) {
    return const UiErrorState(
      message: 'Could not fetch data. Please check your internet and try again.',
      retryable: true,
    );
  }

  if (lowered.contains('bad request') ||
      lowered.contains('forbidden') ||
      lowered.contains('not allowed') ||
      lowered.contains('unauthorized')) {
    return const UiErrorState(
      message: 'Action not permissible.',
      retryable: false,
    );
  }

  return const UiErrorState(
    message: 'Could not fetch data. Please try again.',
    retryable: true,
  );
}
