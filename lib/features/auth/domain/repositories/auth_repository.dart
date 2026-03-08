import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';

/// Represents and Defines the authentication operations
/// required by the application.
///
/// This interface ensures that the presentation layer interacts
/// with authentication logic through abstraction.
abstract class AuthRepository {
  /// Logs user into the application.
  ///
  /// Takes the user's [email] and [password] to authenticate user
  ///
  /// Returns the authenticated [AuthUserEntity] if the login succeeds.
  ///
  /// Throws an exception if credentials are invalid
  /// or if authentication request fails.
  Future<AuthUserEntity> login(String email, String password);

  /// Registers a new user account.
  ///
  /// Requires a valid [email], [password] and unique [username].
  ///
  /// Returns the newly created authenticated user entity.
  Future<AuthUserEntity> register(
    String email,
    String password,
    String username,
  );

  /// Logs the current user out of the application.
  Future<void> logout();
}
