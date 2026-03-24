import 'package:dio/dio.dart';
import 'package:software_project/core/network/api_endpoints.dart';
import '../dto/check_email_request_dto.dart';
import '../dto/login_request_dto.dart';
import '../dto/register_request_dto.dart';
import '../dto/verify_email_request_dto.dart';

/// Handles all raw HTTP calls for authentication.
///
/// Each method maps directly to one Tunify backend endpoint.
/// No business logic here — only the network call and returning [Response].
class AuthApi {
  final Dio _dio;

  const AuthApi(this._dio);

  /// POST /auth/check-email
  Future<Response<dynamic>> checkEmail(CheckEmailRequestDto dto) =>
      _dio.post(ApiEndpoints.checkEmail, data: dto.toJson());

  /// POST /auth/register
  Future<Response<dynamic>> register(RegisterRequestDto dto) =>
      _dio.post(ApiEndpoints.register, data: dto.toJson());

  /// POST /auth/verify-email
  Future<Response<dynamic>> verifyEmail(VerifyEmailRequestDto dto) =>
      _dio.post(ApiEndpoints.verifyEmail, data: dto.toJson());

  /// POST /auth/resend-verification
  Future<Response<dynamic>> resendVerification(String email) =>
      _dio.post(ApiEndpoints.resendVerification, data: {'email': email});

  /// POST /auth/login
  Future<Response<dynamic>> login(LoginRequestDto dto) =>
      _dio.post(ApiEndpoints.login, data: dto.toJson());

  /// POST /auth/google
  ///
  /// Sends the authorization code from Google Sign-In to the backend.
  /// Backend exchanges the code with Google and returns:
  ///   - Scenario 1/2: { accessToken, refreshToken, user }
  ///   - Scenario 3:   { requiresLinking: true, linkingToken }
  ///
  /// The authorization code expires in ~60 seconds — call immediately.
  Future<Response<dynamic>> oauthGoogle({required String code}) =>
      _dio.post(ApiEndpoints.oauthGoogle, data: {'code': code});

  /// POST /auth/google/link
  ///
  /// Called ONLY when POST /auth/google returns requiresLinking: true.
  /// Links the Google account to an existing local Tunify account.
  /// The linkingToken expires in 10 minutes.
  Future<Response<dynamic>> oauthGoogleLink({
    required String linkingToken,
    required String password,
  }) => _dio.post(
    ApiEndpoints.oauthGoogleLink,
    data: {'linkingToken': linkingToken, 'password': password},
  );

  /// POST /auth/signout
  Future<Response<dynamic>> signOut(String refreshToken) =>
      _dio.post(ApiEndpoints.signOut, data: {'refreshToken': refreshToken});

  /// POST /auth/signout-all
  Future<Response<dynamic>> signOutAll(String refreshToken) =>
      _dio.post(ApiEndpoints.signOutAll, data: {'refreshToken': refreshToken});

  /// POST /auth/forgot-password
  Future<Response<dynamic>> forgotPassword(String email) =>
      _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});

  /// POST /auth/reset-password
  Future<Response<dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
    bool signoutAll = true,
  }) => _dio.post(
    ApiEndpoints.resetPassword,
    data: {
      'email': email,
      'token': token,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
      'signoutAll': signoutAll,
    },
  );

  /// DELETE /auth/delete-account
  Future<Response<dynamic>> deleteAccount({String? password}) => _dio.delete(
    ApiEndpoints.deleteAccount,
    data: password != null ? {'password': password} : null,
  );
}
