import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';

/// Handles user registration within the application.
///
/// This use case coordinates the account creation process
/// between the presentation layer and the authentication repository.
///
/// It ensures that registration requests follow domain rules
/// before delegating the operation to the repository.
class RegisterUseCase {
  /// Repository used to perform authentication operations.
  final AuthRepository repository;

  /// Creates an instance of [RegisterUseCase].
  const RegisterUseCase(this.repository);

  /// Executes the user registration process.
  ///
  /// Requires a valid [email], [password], and unique [username].
  ///
  /// Returns an [AuthUserEntity] representing the newly
  /// created authenticated user.
  ///
  /// Throws an exception if registration fails.
  Future<AuthUserEntity> call(String email, String password, String username) {
    return repository.register(email, password, username);
  }
}
