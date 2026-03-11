import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';

/// Handles OAuth authentication for users signing in
/// via a third-party identity provider such as Google.
///
/// This use case coordinates the OAuth login flow between
/// the presentation layer and the authentication repository.
///
/// It delegates the actual authentication to [AuthRepository.oauthLogin],
/// keeping the presentation layer decoupled from data-layer details.
class OAuthLoginUseCase {
  /// Repository used to perform the OAuth authentication operation.
  final AuthRepository repository;

  /// Creates an instance of [OAuthLoginUseCase].
  const OAuthLoginUseCase(this.repository);

  /// Executes the OAuth login process.
  ///
  /// [provider] is the name of the OAuth identity provider
  /// (e.g. `"google"`).
  ///
  /// [token] is the identity token obtained from the provider
  /// after the user completes their consent flow on the client side.
  ///
  /// Returns an [AuthUserEntity] representing the authenticated user
  /// if the operation succeeds.
  ///
  /// Throws a [Failure] if the token is invalid, the provider
  /// is unsupported, or if a network or server error occurs.
  Future<AuthUserEntity> call(String provider, String token) {
    return repository.oauthLogin(provider, token);
  }
}
