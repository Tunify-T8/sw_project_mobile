import 'package:dio/dio.dart';
import 'package:software_project/features/auth/data/dto/login_request_dto.dart';
import 'package:software_project/features/auth/data/dto/register_request_dto.dart';

/// Service responsible for communicating with
/// the backend authentication API.
///
/// This class handles HTTP requests related
/// to authentication operations.
class AuthApi {
  /// HTTP client used for sending API requests.
  final Dio dio;

  /// Creates an instance of [AuthApi].
  const AuthApi(this.dio);

  /// Sends a login request to the backend.
  ///
  /// Requires a [LoginRequestDTO] containing
  /// user login credentials.
  Future<Response> login(LoginRequestDTO request) {
    return dio.post("/auth/login", data: request.toJson());
  }

  /// Sends a registration request to the backend.
  ///
  /// Requires a [RegisterRequestDTO]
  /// containing new user information.
  Future<Response> register(RegisterRequestDTO request) {
    return dio.post("/auth/register", data: request.toJson());
  }

  Future<Response> oauthLogin(String provider, String token) {
    return dio.post(
      "/auth/oauth",
      data: {"provider": provider, "token": token},
    );
  }
}
