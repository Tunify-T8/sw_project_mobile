import 'package:dio/dio.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/core/errors/network_exceptions.dart';
import 'package:software_project/core/storage/token_storage.dart';
import 'package:software_project/features/auth/data/api/auth_api.dart';
import 'package:software_project/features/auth/data/dto/auth_response_dto.dart';
import 'package:software_project/features/auth/data/dto/check_email_request_dto.dart';
import 'package:software_project/features/auth/data/dto/login_request_dto.dart';
import 'package:software_project/features/auth/data/dto/login_response_dto.dart';
import 'package:software_project/features/auth/data/dto/register_request_dto.dart';
import 'package:software_project/features/auth/data/dto/verify_email_request_dto.dart';
import 'package:software_project/features/auth/data/mappers/auth_user_mapper.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Bridges the domain layer to the Tunify backend via [AuthApi].
/// All token persistence is handled through [TokenStorage].
class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;
  final TokenStorage _tokenStorage;

  const AuthRepositoryImpl(this._api, this._tokenStorage);

  @override
  Future<bool> checkEmail(String email) async {
    try {
      final response = await _api.checkEmail(
        CheckEmailRequestDto(email: email),
      );
      return response.data['exists'] as bool;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) async {
    try {
      await _api.register(
        RegisterRequestDto(
          email: email,
          username: username,
          password: password,
          gender: gender,
          dateOfBirth: dateOfBirth,
        ),
      );
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<AuthUserEntity> verifyEmail(String email, String token) async {
    try {
      final response = await _api.verifyEmail(
        VerifyEmailRequestDto(email: email, token: token),
      );
      final dto = AuthResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _tokenStorage.saveTokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      );
      return AuthUserMapper.toEntity(dto);
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<void> resendVerification(String email) async {
    try {
      await _api.resendVerification(email);
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<AuthUserEntity> login(String email, String password) async {
    try {
      final response = await _api.login(
        LoginRequestDto(email: email, password: password),
      );
      final dto = LoginResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Unverified user — backend returns 200 with no tokens.
      if (!dto.isVerified) {
        throw const UnverifiedUserFailure();
      }

      await _tokenStorage.saveTokens(
        accessToken: dto.accessToken!,
        refreshToken: dto.refreshToken!,
      );

      return AuthUserEntity(
        id: dto.userId,
        email: dto.email,
        username: dto.username,
        role: dto.role ?? 'LISTENER',
        isVerified: true,
        avatarUrl: dto.avatarUrl,
      );
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } on Failure {
      rethrow;
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _api.signOut(refreshToken);
      }
    } finally {
      // Always clear local tokens even if the network call fails.
      await _tokenStorage.clearTokens();
    }
  }

  @override
  Future<void> signOutAll() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _api.signOutAll(refreshToken);
      }
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _api.forgotPassword(email);
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
    bool signoutAll = true,
  }) async {
    try {
      await _api.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        signoutAll: signoutAll,
      );
      if (signoutAll) await _tokenStorage.clearTokens();
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    try {
      await _api.deleteAccount(password: password);
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } catch (_) {
      throw const UnknownFailure();
    } finally {
      await _tokenStorage.clearTokens();
    }
  }
}
