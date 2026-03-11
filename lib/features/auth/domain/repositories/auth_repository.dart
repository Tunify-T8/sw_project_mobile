import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';

/// Defines the authentication operations required by the application.
///
/// This interface ensures that the presentation layer interacts
/// with authentication logic through abstraction,
/// keeping the domain layer decoupled from data sources.
abstract class AuthRepository {
  /// Logs user into the application using email and password.
  ///
  /// Returns the authenticated [AuthUserEntity] if the login succeeds.
  ///
  /// Throws an exception if credentials are invalid
  /// or if the authentication request fails.
  Future<AuthUserEntity> login(String email, String password);

  /// Registers a new user account.
  ///
  /// Requires a valid [email], [password], and unique [username].
  ///
  /// Returns the newly created authenticated [AuthUserEntity].
  Future<AuthUserEntity> register(
    String email,
    String password,
    String username,
  );

  /// Authenticates a user via an OAuth [provider] using an identity [token].
  ///
  /// [provider] is the OAuth provider name (e.g. "google").
  /// [token] is the identity token obtained from the provider.
  ///
  /// Returns the authenticated [AuthUserEntity] on success.
  Future<AuthUserEntity> oauthLogin(String provider, String token);

  /// Logs the current user out of the application.
  ///
  /// Clears all locally stored authentication tokens.
  Future<void> logout();
}
