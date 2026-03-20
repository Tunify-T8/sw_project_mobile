import 'package:software_project/features/auth/data/dto/auth_response_dto.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';

/// Maps [AuthResponseDto] to [AuthUserEntity].
class AuthUserMapper {
  AuthUserMapper._();

  static AuthUserEntity toEntity(AuthResponseDto dto) {
    return AuthUserEntity(
      id: dto.userId,
      email: dto.email,
      username: dto.username,
      role: dto.role,
      isVerified: dto.isVerified,
      avatarUrl: dto.avatarUrl,
    );
  }
}
