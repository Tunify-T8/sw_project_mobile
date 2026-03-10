import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';

/// Use case responsible for logging the user out
/// of the application.
///
/// This clears authentication state and removes
/// any stored authentication tokens.
class LogoutUseCase {
  /// Authentication repository used to perform logout operation.
  final AuthRepository repository;

  /// Creates an instance of [LogoutUseCase].
  const LogoutUseCase(this.repository);

  /// Executes the logout process.
  ///
  /// Calls the repository to clear authentication session
  /// and remove stored credentials.
  Future<void> call() {
    return repository.logout();
  }
}
