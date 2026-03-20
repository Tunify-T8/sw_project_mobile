import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

/// Authenticates a user with email and password.
class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);
  Future<AuthUserEntity> call(String email, String password) =>
      _repository.login(email, password);
}
