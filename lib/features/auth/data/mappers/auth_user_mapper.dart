import 'package:software_project/features/auth/data/dto/user_dto.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';

/// Mapper responsible for converting authentication
/// data models into domain entities.
///
/// This mapper ensures that the domain layer remains
/// independent from API response structures.
class AuthUserMapper {
  /// Converts a [UserDTO] into an [AuthUserEntity].
  ///
  /// Used by the repository implementation when transforming
  /// API responses into domain entities.
  static AuthUserEntity toEntity(UserDTO dto) {
    return AuthUserEntity(id: dto.id, email: dto.email, username: dto.username);
  }
}
