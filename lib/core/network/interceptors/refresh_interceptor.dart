import 'dart:async';
import 'package:dio/dio.dart';
import 'package:software_project/core/storage/token_storage.dart';
import '../api_endpoints.dart';

/// Automatically handles expired access tokens.
///
/// When a request returns 401, this interceptor attempts to refresh the
/// access token using the stored refresh token. If refreshing succeeds, it
/// retries the original request with the new access token.
///
/// If refreshing fails (e.g. refresh token expired), stored tokens are cleared
/// and the error is propagated.
///
/// Only one refresh attempt runs at a time; concurrent 401s wait for the
/// active refresh to complete and then retry with the updated token.
class RefreshInterceptor extends Interceptor {
  /// The Dio instance used for the refresh request and the retry.
  final Dio dio;

  /// Secure storage for reading and writing token pairs.
  final TokenStorage tokenStorage;

  /// Guards against concurrent refresh attempts.
  bool _isRefreshing = false;

  /// Completers waiting for an in-progress refresh to finish.
  /// Each completer is resolved with the new access token on success,
  /// or completed with an error on failure.
  final List<Completer<String>> _queue = [];

  RefreshInterceptor(this.dio, this.tokenStorage);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      return handler.next(err);
    }

    // If a refresh is already running, queue this request to retry once done.
    if (_isRefreshing) {
      final completer = Completer<String>();
      _queue.add(completer);

      try {
        final newToken = await completer.future;
        final retryResponse = await _retryRequest(err.requestOptions, newToken);
        return handler.resolve(retryResponse);
      } catch (_) {
        return handler.next(err);
      }
    }

    _isRefreshing = true;

    try {
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      await tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Resolve all queued requests with the new token.
      for (final completer in _queue) {
        completer.complete(newAccessToken);
      }
      _queue.clear();

      // Retry the failed request using a cloned options object so the
      // original request details are not modified.
      final retryResponse = await _retryRequest(
        err.requestOptions,
        newAccessToken,
      );
      return handler.resolve(retryResponse);
    } catch (_) {
      // Reject all queued requests.
      for (final completer in _queue) {
        completer.completeError(err);
      }
      _queue.clear();

      await tokenStorage.clearTokens();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Retries [original] with a fresh [newAccessToken].
  ///
  /// Creates a clean [Options] copy so the original [RequestOptions] object
  /// is never mutated.
  Future<Response<dynamic>> _retryRequest(
    RequestOptions original,
    String newAccessToken,
  ) {
    return dio.request<dynamic>(
      original.path,
      data: original.data,
      queryParameters: original.queryParameters,
      options: Options(
        method: original.method,
        headers: {
          ...original.headers,
          'Authorization': 'Bearer $newAccessToken',
        },
        contentType: original.contentType,
        responseType: original.responseType,
        sendTimeout: original.sendTimeout,
        receiveTimeout: original.receiveTimeout,
      ),
    );
  }
}
