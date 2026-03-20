import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'mock_auth_config.dart';

/// Fake implementations of every auth operation.
///
/// This version keeps a tiny in-memory user store so signup and login can both
/// be tested in the same app run without manually flipping mock scenarios.
class MockAuthService {
  MockAuthService._();

  static int _idCounter = 2;

  static final Map<String, _MockStoredUser> _usersByEmail = {
    'robin.banks.dealer911@gmail.com': _MockStoredUser(
      id: 'mock-user-001',
      email: 'robin.banks.dealer911@gmail.com',
      username: 'Robin Banks',
      role: 'LISTENER',
      isVerified: true,
      password: '123456',
    ),
  };

  static Future<bool> checkEmail(String email) async {
    await Future.delayed(MockAuthConfig.delay);
    final normalizedEmail = email.trim().toLowerCase();
    final stored = _usersByEmail[normalizedEmail];
    if (stored != null) {
      return true;
    }
    return MockAuthConfig.emailScenario == MockEmailScenario.existingAccount;
  }

  static Future<void> register({
    required String email,
    required String username,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) async {
    await Future.delayed(MockAuthConfig.delay);
    switch (MockAuthConfig.registerScenario) {
      case MockRegisterScenario.success:
        final normalizedEmail = email.trim().toLowerCase();
        if (_usersByEmail.containsKey(normalizedEmail)) {
          throw const ConflictFailure('This email is already in use.');
        }
        final duplicateUsername = _usersByEmail.values.any(
          (user) => user.username.toLowerCase() == username.trim().toLowerCase(),
        );
        if (duplicateUsername) {
          throw const ConflictFailure('This username is already taken.');
        }
        _usersByEmail[normalizedEmail] = _MockStoredUser(
          id: 'mock-user-${_idCounter++}',
          email: normalizedEmail,
          username: username.trim(),
          role: 'ARTIST',
          isVerified: false,
          password: password,
        );
        return;
      case MockRegisterScenario.emailTaken:
        throw const ConflictFailure('This email is already in use.');
      case MockRegisterScenario.usernameTaken:
        throw const ConflictFailure('This username is already taken.');
    }
  }

  static Future<AuthUserEntity> verifyEmail({
    required String email,
    required String token,
  }) async {
    await Future.delayed(MockAuthConfig.delay);
    switch (MockAuthConfig.verifyScenario) {
      case MockVerifyScenario.success:
        final normalizedEmail = email.trim().toLowerCase();
        final stored = _usersByEmail[normalizedEmail];
        if (stored == null) {
          throw const NotFoundFailure('Account not found.');
        }
        final verified = stored.copyWith(isVerified: true);
        _usersByEmail[normalizedEmail] = verified;
        return verified.toEntity();
      case MockVerifyScenario.invalidToken:
        throw const UnauthorizedFailure();
    }
  }

  static Future<AuthUserEntity> login(String email, String password) async {
    await Future.delayed(MockAuthConfig.delay);
    switch (MockAuthConfig.loginScenario) {
      case MockLoginScenario.success:
        final normalizedEmail = email.trim().toLowerCase();
        final stored = _usersByEmail[normalizedEmail];
        if (stored == null) {
          throw const UnauthorizedFailure();
        }
        if (!stored.isVerified) {
          throw const UnverifiedUserFailure();
        }
        if (stored.password != password) {
          throw const UnauthorizedFailure();
        }
        return stored.toEntity();
      case MockLoginScenario.wrongPassword:
        throw const UnauthorizedFailure();
      case MockLoginScenario.unverified:
        throw const UnverifiedUserFailure();
    }
  }

  static Future<void> forgotPassword(String email) async {
    await Future.delayed(MockAuthConfig.delay);
    switch (MockAuthConfig.forgotScenario) {
      case MockForgotScenario.success:
        return;
      case MockForgotScenario.invalidEmail:
        throw const ValidationFailure('Invalid email address format.');
    }
  }

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

  static Future<void> logout() async {
    await Future.delayed(MockAuthConfig.delay);
  }
}

class _MockStoredUser {
  final String id;
  final String email;
  final String username;
  final String role;
  final bool isVerified;
  final String password;

  const _MockStoredUser({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.isVerified,
    required this.password,
  });

  _MockStoredUser copyWith({
    String? id,
    String? email,
    String? username,
    String? role,
    bool? isVerified,
    String? password,
  }) {
    return _MockStoredUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      password: password ?? this.password,
    );
  }

  AuthUserEntity toEntity() {
    return AuthUserEntity(
      id: id,
      email: email,
      username: username,
      role: role,
      isVerified: isVerified,
    );
  }
}
