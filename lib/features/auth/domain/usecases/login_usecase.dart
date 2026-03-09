import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';

/// Handles the login authentication process for users.
///
/// This use case coordinates the login request between
/// the presentation layer and the authentication repository.
///
/// It ensures that login operations follow the domain rules
/// before delegating authentication to the repository.
class LoginUseCase {
  /// Repository used to perform authentication operations.
  final AuthRepository repository;

  /// Creates an instance of [LoginUseCase].
  const LoginUseCase(this.repository);

  /// Executes the login process.
  ///
  /// Requires a valid [email] and [password].
  ///
  /// Returns an [AuthUserEntity] representing the authenticated user
  /// if the login operation succeeds.
  ///
  /// Throws an exception if authentication fails.
  Future<AuthUserEntity> call(String email, String password) {
    return repository.login(email, password);
  }
}
