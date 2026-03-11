import 'package:software_project/core/storage/token_storage.dart';
import 'package:software_project/features/auth/data/api/auth_api.dart';
import 'package:software_project/features/auth/data/dto/auth_response_dto.dart';
import 'package:software_project/features/auth/data/dto/login_request_dto.dart';
import 'package:software_project/features/auth/data/dto/register_request_dto.dart';
import 'package:software_project/features/auth/data/mappers/auth_user_mapper.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// This class belongs to the data layer and is responsible for
/// handling authentication operations by communicating with
/// the backend API through [AuthApi].
///
/// It converts API responses (DTOs) into domain entities using
/// mappers, ensuring the domain layer stays decoupled from
/// API response structures.
class AuthRepositoryImpl implements AuthRepository {
  /// The API client used for network requests.
  final AuthApi api;

  /// Storage used to persist authentication tokens securely.
  final TokenStorage tokenStorage;

  /// Creates an instance of [AuthRepositoryImpl].
  const AuthRepositoryImpl(this.api, this.tokenStorage);

  /// Signs in a user with [email] and [password].
  ///
  /// Calls [AuthApi.login], parses the response into an [AuthResponseDTO],
  /// stores the returned tokens, and maps the user to [AuthUserEntity].
  @override
  Future<AuthUserEntity> login(String email, String password) async {
    final request = LoginRequestDTO(email: email, password: password);

    final response = await api.login(request);

    final dto = AuthResponseDTO.fromJson(response.data);

    await tokenStorage.saveTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );

    return AuthUserMapper.toEntity(dto.user);
  }

  /// Registers a new user with [email], [password], and [username].
  ///
  /// Calls [AuthApi.register], parses the response, stores the returned
  /// tokens, and maps the user to [AuthUserEntity].
  @override
  Future<AuthUserEntity> register(
    String email,
    String password,
    String username,
  ) async {
    final request = RegisterRequestDTO(
      email: email,
      password: password,
      username: username,
    );

    final response = await api.register(request);

    final dto = AuthResponseDTO.fromJson(response.data);

    await tokenStorage.saveTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );

    return AuthUserMapper.toEntity(dto.user);
  }

  /// Authenticates a user via OAuth using the given [provider] and [token].
  ///
  /// Calls [AuthApi.oauthLogin], stores the returned tokens,
  /// and maps the user to [AuthUserEntity].
  @override
  Future<AuthUserEntity> oauthLogin(String provider, String token) async {
    final response = await api.oauthLogin(provider, token);

    final dto = AuthResponseDTO.fromJson(response.data);

    await tokenStorage.saveTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );

    return AuthUserMapper.toEntity(dto.user);
  }

  /// Logs out the current user by clearing stored tokens.
  @override
  Future<void> logout() async {
    await tokenStorage.clearTokens();
  }
}
