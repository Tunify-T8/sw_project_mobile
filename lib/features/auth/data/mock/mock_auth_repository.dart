import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';
import 'mock_auth_config.dart';
import 'mock_auth_service.dart';

/// Fake implementation of [AuthRepository] used during development
/// when [MockAuthConfig.useMock] is true.
///
/// Every method delegates to [MockAuthService] which reads scenario enums
/// from [MockAuthConfig] and returns controlled results or throws typed
/// [Failure]s — exactly what the real repository would do.
///
/// Screens and use cases never know this exists.
/// The single switch is in [authRepositoryProvider] in auth_provider.dart.
class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<bool> checkEmail(String email) => MockAuthService.checkEmail(email);

  @override
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) => MockAuthService.register();

  @override
  Future<AuthUserEntity> login(String email, String password) =>
      MockAuthService.login(email, password);

  @override
  Future<AuthUserEntity> verifyEmail(String email, String token) =>
      MockAuthService.verifyEmail();

  @override
  Future<void> resendVerification(String email) async {
    // No scenario needed — resend always succeeds in mock mode.
    await Future.delayed(MockAuthConfig.delay);
  }

  @override
  Future<void> forgotPassword(String email) =>
      MockAuthService.forgotPassword(email);

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
    bool signoutAll = true,
  }) => MockAuthService.resetPassword();

  @override
  Future<void> deleteAccount({String? password}) =>
      MockAuthService.deleteAccount();

  @override
  Future<void> signOut() => MockAuthService.logout();

  @override
  Future<void> signOutAll() => MockAuthService.logout();
}
