import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

/// Verifies the user's email and returns the authenticated user with tokens.
class VerifyEmailUseCase {
  final AuthRepository _repository;
  const VerifyEmailUseCase(this._repository);
  Future<AuthUserEntity> call(String email, String token) =>
      _repository.verifyEmail(email, token);
}
