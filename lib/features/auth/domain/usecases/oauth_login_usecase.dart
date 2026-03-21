import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

/// Authenticates a user via a third-party OAuth provider.
///
/// The flow:
///   1. Flutter gets an ID token from the provider (e.g. Google).
///   2. This use case sends that token to your backend.
///   3. The backend verifies it with Google, creates/fetches the user,
///      and returns your own JWT pair.
///   4. The repository saves the session and returns [AuthUserEntity].
///
/// Currently supports: Google (provider = 'google')
/// Pending backend support: Facebook, Apple
///
/// Usage:
/// ```dart
/// final user = await oauthLoginUseCase(
///   idToken: result.idToken,
///   provider: 'google',
/// );
/// ```
class OAuthLoginUseCase {
  final AuthRepository _repository;
  const OAuthLoginUseCase(this._repository);

  Future<AuthUserEntity> call({
    required String idToken,
    required String provider,
  }) => _repository.oauthLogin(idToken: idToken, provider: provider);
}
