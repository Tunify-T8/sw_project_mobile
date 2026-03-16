import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(const TokenStorage());
});

class DioClient {
  DioClient._();

  static Dio create(TokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(tokenStorage));
    dio.interceptors.add(RefreshInterceptor(dio, tokenStorage));
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );

    return dio;
  }
}
