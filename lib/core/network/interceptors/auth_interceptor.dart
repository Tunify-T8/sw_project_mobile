import 'package:dio/dio.dart';
import 'package:software_project/core/storage/token_storage.dart';

/// A Dio request interceptor that attaches the JWT access token
/// to every outgoing HTTP request.
///
/// This interceptor runs before each request is dispatched.
/// If a valid access token exists in [TokenStorage], it is injected
/// into the `Authorization` header using the Bearer scheme.
///
/// If no token is found (e.g. the user is unauthenticated),
/// the request proceeds without an `Authorization` header,
/// allowing public endpoints to function normally.
///
/// This interceptor is registered on the [Dio] instance
/// inside [DioClient.create].
class AuthInterceptor extends Interceptor {
  /// Secure storage used to retrieve the current JWT access token.
  final TokenStorage tokenStorage;

  /// Creates an [AuthInterceptor] with the given [tokenStorage].
  AuthInterceptor(this.tokenStorage);

  /// Intercepts outgoing requests to inject the Bearer token.
  ///
  /// Reads the access token from [TokenStorage]. If a token is present,
  /// it is added to the request headers as:
  /// ```
  /// Authorization: Bearer <token>
  /// ```
  /// Calls [handler.next] to forward the (possibly modified)
  /// request to the next interceptor or the HTTP adapter.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}
