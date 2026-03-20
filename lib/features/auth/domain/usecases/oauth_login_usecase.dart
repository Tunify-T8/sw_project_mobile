import '../repositories/auth_repository.dart';

/// Placeholder use case for OAuth login via third-party providers.
///
/// The Tunify API doc marks POST /auth/google as "Coming Soon".
/// This class will be implemented once the backend endpoint is available.
///
/// For now, OAuth is handled directly in [AuthController.loginWithGoogle]
/// using the [GoogleSignInService] to obtain an identity token,
/// without a matching backend call.
///
/// TODO: Implement once POST /auth/google is available on the backend.
class OAuthLoginUseCase {
  // ignore: unused_field
  final AuthRepository _repository;

  const OAuthLoginUseCase(this._repository);
}
