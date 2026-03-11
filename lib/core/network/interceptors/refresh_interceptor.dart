import 'package:dio/dio.dart';
import 'package:software_project/core/storage/token_storage.dart';
import '../api_endpoints.dart';

/// A Dio error interceptor that automatically handles expired access tokens.
///
/// When a request fails with HTTP `401 Unauthorized`, this interceptor
/// attempts to obtain a new access token using the stored refresh token.
/// If the token refresh succeeds, the original failed request is retried
/// transparently with the new access token.
///
/// If the refresh token is missing or the refresh request itself fails,
/// all stored tokens are cleared (effectively logging the user out)
/// and the original error is forwarded to the caller.
///
/// This interceptor is registered on the [Dio] instance
/// inside [DioClient.create] and must be added after [AuthInterceptor]
/// so that the initial request already carries the access token
/// before this interceptor evaluates the response.
class RefreshInterceptor extends Interceptor {
  /// The [Dio] instance used to perform the token refresh request.
  ///
  /// The same instance is reused to retry the original failed request,
  /// which also means [AuthInterceptor] will attach the new token
  /// automatically on retry.
  final Dio dio;

  /// Secure storage used to read the refresh token
  /// and persist the newly issued token pair.
  final TokenStorage tokenStorage;

  /// Creates a [RefreshInterceptor] with the given [dio] client
  /// and [tokenStorage].
  RefreshInterceptor(this.dio, this.tokenStorage);

  /// Intercepts HTTP errors to handle token expiry.
  ///
  /// When the response status code is `401`:
  /// 1. Reads the refresh token from [TokenStorage].
  /// 2. If no refresh token exists, forwards the original error unchanged.
  /// 3. Posts to [ApiEndpoints.refreshToken] with the refresh token.
  /// 4. Persists the newly issued access and refresh tokens via [TokenStorage].
  /// 5. Retries the original request with the updated `Authorization` header.
  ///
  /// If the refresh request fails for any reason, [TokenStorage.clearTokens]
  /// is called to remove all credentials, then the original error is forwarded.
  ///
  /// For all non-401 errors, the error is forwarded to the next handler
  /// without modification.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null) {
        return handler.next(err);
      }

      try {
        final response = await dio.post(
          ApiEndpoints.refreshToken,
          data: {"refreshToken": refreshToken},
        );

        final newAccessToken = response.data["accessToken"] as String;
        final newRefreshToken = response.data["refreshToken"] as String;

        await tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        final options = err.requestOptions;
        options.headers["Authorization"] = "Bearer $newAccessToken";

        final retryResponse = await dio.fetch(options);

        return handler.resolve(retryResponse);
      } catch (_) {
        await tokenStorage.clearTokens();
      }
    }

    handler.next(err);
  }
}
