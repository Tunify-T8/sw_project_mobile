import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';

class OAuthLoginUseCase {
  final AuthRepository repository;

  OAuthLoginUseCase(this.repository);

  Future<AuthUserEntity> call(String provider, String token) {
    return repository.oauthLogin(provider, token);
  }
}
