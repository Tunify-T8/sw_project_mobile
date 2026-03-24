import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

/// Links a Google account to an existing local Tunify account.
///
/// Called only after [OAuthGoogleSignInUseCase] throws
/// [GoogleAccountLinkingRequiredFailure] (Scenario 3).
///
/// [linkingToken] expires in 10 minutes.
/// [password] is the user's existing Tunify password.
class LinkGoogleAccountUseCase {
  final AuthRepository _repository;
  const LinkGoogleAccountUseCase(this._repository);

  Future<AuthUserEntity> call({
    required String linkingToken,
    required String password,
  }) => _repository.linkGoogleAccount(
    linkingToken: linkingToken,
    password: password,
  );
}
