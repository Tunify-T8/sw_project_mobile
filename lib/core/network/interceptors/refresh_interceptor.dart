import 'package:dio/dio.dart';
import 'package:software_project/core/storage/token_storage.dart';
import '../api_endpoints.dart';

class RefreshInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage tokenStorage;

  RefreshInterceptor(this.dio, this.tokenStorage);

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

        final newAccessToken = response.data["accessToken"];
        final newRefreshToken = response.data["refreshToken"];

        await tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        final options = err.requestOptions;

        options.headers["Authorization"] = "Bearer $newAccessToken";

        final cloneReq = await dio.fetch(options);

        return handler.resolve(cloneReq);
      } catch (_) {
        await tokenStorage.clearTokens();
      }
    }

    handler.next(err);
  }
}
