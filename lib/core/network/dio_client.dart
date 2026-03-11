import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';

/// Provides a configured instance of [Dio]
/// used for performing HTTP requests across the application.
///
/// Centralizing the HTTP client allows consistent
/// configuration of base URL, headers, interceptors,
/// and request timeouts.
class DioClient {
  /// Base URL for backend API.
  /// TODO: Replace with real backend URL once available.
  static const String baseUrl = "";

  /// Creates and configures a [Dio] instance.
  ///
  /// Attaches [AuthInterceptor] to inject the JWT access token
  /// into every outgoing request, and [RefreshInterceptor] to
  /// automatically refresh expired tokens on 401 responses.
  static Dio create(TokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );

    dio.interceptors.add(AuthInterceptor(tokenStorage));
    dio.interceptors.add(RefreshInterceptor(dio, tokenStorage));

    return dio;
  }
}
