import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_endpoints.dart';
// Instead of making raw requests everywhere with new Dio objects, this file says:

// “Use one shared Dio instance that already knows the base URL, timeouts, headers, token logic, and logging.
// note for integration: this is a shared network client, not specific to uploads. It can be used for any API calls in the app, but we start with upload-related ones.
final authTokenProvider = Provider<String?>((ref) {
  // Replace this later with your real auth storage/provider. integration will be easier if you have a real one, but for now we just want to test the network layer, so we can hardcode a token here.
  return null;
});

final dioProvider = Provider<Dio>((ref) { //why use provider for Dio? Because we want to inject the auth token from another provider, and we want to have a single shared instance of Dio with all the configuration and interceptors set up. This way, we can easily access Dio from anywhere in the app by reading this provider, and it will automatically include the auth token in the headers of every request.
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        // “I expect JSON responses.”
      },
    ),
  );
  // dio.get('/tracks/123')
  // http://10.0.2.2:3000/api/tracks/123
// So you do not need to rewrite the full URL every time
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authTokenProvider);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options); //so it continues with the request
      },
      onError: (error, handler) { 
        handler.next(error);
      },
    ),
  );
// read current token
// if token exists
// attach it as Authorization header
// the interceptor does it once for all requests

  dio.interceptors.add( //explain interceptors : they are like middleware for your HTTP requests. You can use them to modify requests before they are sent, or responses before they are processed by your app. Here we use one to add the auth token to every request, and another to log the request and response data for debugging.
    LogInterceptor( //for debugging
      requestBody: true,
      responseBody: true,
    ),
  );

  return dio;
}); /*import 'package:dio/dio.dart';
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
} */
