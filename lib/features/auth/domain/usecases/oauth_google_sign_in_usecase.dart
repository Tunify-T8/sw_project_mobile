import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

/// Signs in with Google using the authorization code flow.
///
/// Sends the serverAuthCode from the Google Sign-In SDK to the backend.
/// Three outcomes:
///   1. New user → account created, session saved, returns user.
///   2. Returning user → session saved, returns user.
///   3. Email conflict → throws [GoogleAccountLinkingRequiredFailure].
///      UI must show the account linking screen.
class OAuthGoogleSignInUseCase {
  final AuthRepository _repository;
  const OAuthGoogleSignInUseCase(this._repository);

  Future<AuthUserEntity> call({required String authorizationCode}) =>
      _repository.oauthGoogleSignIn(authorizationCode: authorizationCode);
}
