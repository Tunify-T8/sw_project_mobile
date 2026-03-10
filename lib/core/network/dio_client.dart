import 'package:dio/dio.dart';

/// Provides a configured instance of [Dio]
/// used for performing HTTP requests across the application.
///
/// Centralizing the HTTP client allows consistent
/// configuration of base URL, headers, interceptors,
/// and request timeouts.
class DioClient {
  /// Base URL for backend API.
  /// TODO: use mock API till backend sends url
  static const String baseUrl = "";

  /// Creates and configures a [Dio] instance.
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    return dio;
  }
}
