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
/// It converts API responses represented as Data Transfer Objects (DTOs)
/// into domain entities using mappers, ensuring that the domain layer
/// remains independent from API response structures.
///
/// Responsibilities:
/// - Sending authentication requests to the backend API.
/// - Parsing authentication responses into DTO models.
/// - Converting DTOs into domain entities.
/// - Returning domain entities to the use cases.
///
/// The logout operation will later be responsible for clearing
/// locally stored authentication tokens once token storage
/// is implemented.
class AuthRepositoryImpl implements AuthRepository {
  /// The API client used for network requests.
  final AuthApi api;

  /// The token storage service
  final TokenStorage tokenStorage;

  /// Creates an instance of [AuthRepositoryImpl] with the required [AuthApi] and [TokenStorage].
  const AuthRepositoryImpl(this.api, this.tokenStorage);

  /// Signs in a user with [email] and [password].
  ///
  /// Calls [AuthApi.login], maps the result to [AuthUserEntity],
  /// and handles any potential exceptions from the API.
  @override
  Future<AuthUserEntity> login(String email, String password) async {
    final request = LoginRequestDTO(email: email, password: password);
    final response = await api.login(request);
    final dto = AuthResponseDTO.fromJson(response.data);
    return AuthUserMapper.toEntity(dto.user);
  }

  /// Registers a new user with [email], [password], and [username].
  ///
  /// Calls [AuthApi.register], maps the result to [AuthUserEntity],
  /// and handles any potential exceptions from the API.
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
    return AuthUserMapper.toEntity(dto.user);
  }

  /// Logs out the current user.
  ///
  /// This method will be implemented to clear locally stored
  /// authentication tokens from secure storage.
  @override
  Future<void> logout() async {
    tokenStorage.clearTokens();
  }
}
