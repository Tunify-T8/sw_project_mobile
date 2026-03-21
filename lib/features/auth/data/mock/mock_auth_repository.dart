import 'package:software_project/core/storage/token_storage.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';
import 'mock_auth_service.dart';

/// Fake implementation of [AuthRepository] used when [MockAuthConfig.useMock] is true.
class MockAuthRepository implements AuthRepository {
  final TokenStorage _tokenStorage;

  const MockAuthRepository({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage;

  @override
  Future<bool> checkEmail(String email) => MockAuthService.checkEmail(email);

  @override
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) => MockAuthService.register(
    email: email,
    username: username,
    password: password,
    gender: gender,
    dateOfBirth: dateOfBirth,
  );

  @override
  Future<AuthUserEntity> login(String email, String password) async {
    final user = await MockAuthService.login(email, password);
    await _tokenStorage.saveSession(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      user: user,
    );
    return user;
  }

  @override
  Future<AuthUserEntity> oauthLogin({
    required String idToken,
    required String provider,
  }) async {
    // Mock OAuth always succeeds with the same fake user.
    // In real mode, the backend verifies the idToken and returns a real user.
    await Future.delayed(const Duration(milliseconds: 700));
    const fakeUser = AuthUserEntity(
      id: 'mock-oauth-001',
      email: 'oauth.user@gmail.com',
      username: 'OAuth User',
      role: 'LISTENER',
      isVerified: true,
    );
    await _tokenStorage.saveSession(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      user: fakeUser,
    );
    return fakeUser;
  }

  @override
  Future<AuthUserEntity> verifyEmail(String email, String token) async {
    final user = await MockAuthService.verifyEmail(email: email, token: token);
    await _tokenStorage.saveSession(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      user: user,
    );
    return user;
  }

  @override
  Future<void> resendVerification(String email) async {
    await Future.delayed(const Duration(milliseconds: 700));
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
  }) async {
    await MockAuthService.resetPassword();
    if (signoutAll) await _tokenStorage.clearSession();
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    await MockAuthService.deleteAccount();
    await _tokenStorage.clearSession();
  }

  @override
  Future<void> signOut() async {
    await MockAuthService.logout();
    await _tokenStorage.clearSession();
  }

  @override
  Future<void> signOutAll() async {
    await MockAuthService.logout();
    await _tokenStorage.clearSession();
  }
}
