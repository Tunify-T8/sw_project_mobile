import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'mock_auth_config.dart';

/// Fake implementations of every auth operation.
///
/// Each method reads the matching scenario from [MockAuthConfig]
/// and either returns fake data or throws the appropriate [Failure].
///
/// No screen code changes needed to switch scenarios —
/// just change the config value and hot-restart.
class MockAuthService {
  MockAuthService._();

  // ── Fake user returned on successful login / verify ────────────────────────
  static const AuthUserEntity _fakeUser = AuthUserEntity(
    id: 'mock-user-001',
    email: 'robin.banks.dealer911@gmail.com',
    username: 'Robin Banks',
    role: 'LISTENER',
    isVerified: true,
  );

  // ── checkEmail ──────────────────────────────────────────────────────────────
  /// Returns true if [MockEmailScenario.existingAccount], false otherwise.
  static Future<bool> checkEmail(String email) async {
    await Future.delayed(MockAuthConfig.delay);
    return MockAuthConfig.emailScenario == MockEmailScenario.existingAccount;
  }

  // ── login ───────────────────────────────────────────────────────────────────
  /// Returns [_fakeUser] or throws based on [MockAuthConfig.loginScenario].
  static Future<AuthUserEntity> login(String email, String password) async {
    await Future.delayed(MockAuthConfig.delay);
    switch (MockAuthConfig.loginScenario) {
      case MockLoginScenario.success:
        return _fakeUser;
      case MockLoginScenario.wrongPassword:
        throw const UnauthorizedFailure();
      case MockLoginScenario.unverified:
        throw const UnverifiedUserFailure();
    }
  }

  // ── register ────────────────────────────────────────────────────────────────
  /// Completes silently or throws based on [MockAuthConfig.registerScenario].
  static Future<void> register() async {
    await Future.delayed(MockAuthConfig.delay);
    switch (MockAuthConfig.registerScenario) {
      case MockRegisterScenario.success:
        return;
      case MockRegisterScenario.emailTaken:
        throw const ConflictFailure('This email is already in use.');
      case MockRegisterScenario.usernameTaken:
        throw const ConflictFailure('This username is already taken.');
    }
  }

  // ── verifyEmail ─────────────────────────────────────────────────────────────
  /// Returns [_fakeUser] or throws based on [MockAuthConfig.verifyScenario].
  static Future<AuthUserEntity> verifyEmail() async {
    await Future.delayed(MockAuthConfig.delay);
    switch (MockAuthConfig.verifyScenario) {
      case MockVerifyScenario.success:
        return _fakeUser;
      case MockVerifyScenario.invalidToken:
        throw const UnauthorizedFailure();
    }
  }

  // ── forgotPassword ──────────────────────────────────────────────────────────
  /// Completes silently (API always returns success — security by design)
  /// or throws a [ValidationFailure] to simulate a bad email format.
  static Future<void> forgotPassword(String email) async {
    await Future.delayed(MockAuthConfig.delay);
    switch (MockAuthConfig.forgotScenario) {
      case MockForgotScenario.success:
        return; // Always navigate to check-your-email regardless.
      case MockForgotScenario.invalidEmail:
        throw const ValidationFailure('Invalid email address format.');
    }
  }

  // ── resetPassword ───────────────────────────────────────────────────────────
  /// Completes silently or throws based on [MockAuthConfig.resetScenario].
  static Future<void> resetPassword() async {
    await Future.delayed(MockAuthConfig.delay);
    switch (MockAuthConfig.resetScenario) {
      case MockResetScenario.success:
        return;
      case MockResetScenario.invalidToken:
        throw const UnauthorizedFailure();
      case MockResetScenario.passwordMismatch:
        throw const ValidationFailure('Passwords do not match.');
    }
  }

  // ── deleteAccount ───────────────────────────────────────────────────────────
  /// Completes silently or throws based on [MockAuthConfig.deleteScenario].
  static Future<void> deleteAccount() async {
    await Future.delayed(MockAuthConfig.delay);
    switch (MockAuthConfig.deleteScenario) {
      case MockDeleteScenario.success:
        return;
      case MockDeleteScenario.wrongPassword:
        throw const UnauthorizedFailure();
      case MockDeleteScenario.banned:
        throw const ForbiddenFailure(
          'Banned accounts cannot be deleted. Please contact support.',
        );
    }
  }

  // ── logout ──────────────────────────────────────────────────────────────────
  /// Always succeeds — clears tokens (handled by repository).
  static Future<void> logout() async {
    await Future.delayed(MockAuthConfig.delay);
    // MockLogoutScenario only has success — logout always works locally.
  }
}
