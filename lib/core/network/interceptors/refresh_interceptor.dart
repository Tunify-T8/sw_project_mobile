import 'package:dio/dio.dart';
import 'package:software_project/core/storage/token_storage.dart';
import '../api_endpoints.dart';

/// Automatically handles expired access tokens.
///
/// On a 401 response from a protected route:
/// 1. Reads the stored refresh token.
/// 2. Calls [ApiEndpoints.refreshToken] to get a new token pair.
/// 3. Saves both new tokens and retries the original request.
///
/// If the refresh call also returns 401 (token expired / revoked),
/// all stored tokens are cleared — the user will need to log in again.
class RefreshInterceptor extends Interceptor {
  /// The Dio instance used for the refresh request and the retry.
  final Dio dio;

  /// Secure storage for reading and writing token pairs.
  final TokenStorage tokenStorage;

  const RefreshInterceptor(this.dio, this.tokenStorage);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      return handler.next(err);
    }

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

      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await dio.fetch(retryOptions);
      return handler.resolve(retryResponse);
    } catch (_) {
      await tokenStorage.clearTokens();
      return handler.next(err);
    }
  }
}
