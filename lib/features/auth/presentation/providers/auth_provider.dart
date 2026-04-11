import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/core/network/dio_client.dart';
import 'package:software_project/core/storage/token_storage.dart';
import 'package:software_project/features/auth/data/api/auth_api.dart';
import 'package:software_project/features/auth/data/mock/mock_auth_config.dart';
import 'package:software_project/features/auth/data/mock/mock_auth_repository.dart';
import 'package:software_project/features/auth/data/repository/auth_repository_impl.dart';
import 'package:software_project/features/auth/data/services/google_sign_in_service.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:software_project/features/auth/domain/usecases/check_email_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/link_google_account_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/login_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/logout_all_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/logout_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/oauth_google_sign_in_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/register_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_provider.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────

final tokenStorageProvider = Provider<TokenStorage>(
  (_) => const TokenStorage(),
);

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(DioClient.create(ref.read(tokenStorageProvider)));
});

final googleSignInServiceProvider = Provider<GoogleSignInService>(
  (_) => GoogleSignInService(),
);

// ─── Repository ───────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);

  if (MockAuthConfig.useMock) {
    return MockAuthRepository(tokenStorage: tokenStorage);
  }

  return AuthRepositoryImpl(ref.read(authApiProvider), tokenStorage);
});

// ─── Use Cases ────────────────────────────────────────────────────────────────

final checkEmailUseCaseProvider = Provider<CheckEmailUseCase>(
  (ref) => CheckEmailUseCase(ref.read(authRepositoryProvider)),
);
final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.read(authRepositoryProvider)),
);
final verifyEmailUseCaseProvider = Provider<VerifyEmailUseCase>(
  (ref) => VerifyEmailUseCase(ref.read(authRepositoryProvider)),
);
final resendVerificationUseCaseProvider = Provider<ResendVerificationUseCase>(
  (ref) => ResendVerificationUseCase(ref.read(authRepositoryProvider)),
);
final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);
final oauthGoogleSignInUseCaseProvider = Provider<OAuthGoogleSignInUseCase>(
  (ref) => OAuthGoogleSignInUseCase(ref.read(authRepositoryProvider)),
);
final linkGoogleAccountUseCaseProvider = Provider<LinkGoogleAccountUseCase>(
  (ref) => LinkGoogleAccountUseCase(ref.read(authRepositoryProvider)),
);
final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.read(authRepositoryProvider)),
);
final logoutAllUseCaseProvider = Provider<LogoutAllUseCase>(
  (ref) => LogoutAllUseCase(ref.read(authRepositoryProvider)),
);
final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>(
  (ref) => ForgotPasswordUseCase(ref.read(authRepositoryProvider)),
);
final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>(
  (ref) => ResetPasswordUseCase(ref.read(authRepositoryProvider)),
);
final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>(
  (ref) => DeleteAccountUseCase(ref.read(authRepositoryProvider)),
);

// ─── Controller ───────────────────────────────────────────────────────────────

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<AuthUserEntity?>>(
      AuthController.new,
    );

class AuthController extends Notifier<AsyncValue<AuthUserEntity?>> {
  CheckEmailUseCase get _checkEmail => ref.read(checkEmailUseCaseProvider);
  RegisterUseCase get _register => ref.read(registerUseCaseProvider);
  VerifyEmailUseCase get _verifyEmail => ref.read(verifyEmailUseCaseProvider);
  ResendVerificationUseCase get _resendVerification =>
      ref.read(resendVerificationUseCaseProvider);
  LoginUseCase get _login => ref.read(loginUseCaseProvider);
  OAuthGoogleSignInUseCase get _oauthGoogleSignIn =>
      ref.read(oauthGoogleSignInUseCaseProvider);
  LinkGoogleAccountUseCase get _linkGoogleAccount =>
      ref.read(linkGoogleAccountUseCaseProvider);
  LogoutUseCase get _logout => ref.read(logoutUseCaseProvider);
  LogoutAllUseCase get _logoutAll => ref.read(logoutAllUseCaseProvider);
  ForgotPasswordUseCase get _forgotPassword =>
      ref.read(forgotPasswordUseCaseProvider);
  ResetPasswordUseCase get _resetPassword =>
      ref.read(resetPasswordUseCaseProvider);
  DeleteAccountUseCase get _deleteAccount =>
      ref.read(deleteAccountUseCaseProvider);
  GoogleSignInService get _googleSignInService =>
      ref.read(googleSignInServiceProvider);
  TokenStorage get _tokenStorage => ref.read(tokenStorageProvider);

  @override
  AsyncValue<AuthUserEntity?> build() => const AsyncData<AuthUserEntity?>(null);

  Future<AuthUserEntity?> restoreSession() async {
    final user = await _tokenStorage.getUser();
    state = AsyncData<AuthUserEntity?>(user);
    return user;
  }

  Future<AuthUserEntity?> syncProfileIdentity({
    required String username,
    required String? avatarUrl,
  }) async {
    final currentUser = state.asData?.value ?? await _tokenStorage.getUser();
    if (currentUser == null) return null;

    final updatedUser = AuthUserEntity(
      id: currentUser.id,
      email: currentUser.email,
      username: username,
      role: currentUser.role,
      isVerified: currentUser.isVerified,
      avatarUrl: avatarUrl,
    );

    await _tokenStorage.saveUser(updatedUser);
    state = AsyncData<AuthUserEntity?>(updatedUser);
    return updatedUser;
  }

  Future<bool> checkEmail(String email) async {
    try {
      return await _checkEmail(email);
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
      return false;
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) async {
    state = const AsyncLoading<AuthUserEntity?>();
    try {
      await _register(
        email: email,
        username: username,
        password: password,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      state = const AsyncData<AuthUserEntity?>(null);
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
    }
  }

  Future<void> verifyEmail(String email, String token) async {
    state = const AsyncLoading<AuthUserEntity?>();
    try {
      final user = await _verifyEmail(email, token);
      state = AsyncData<AuthUserEntity?>(user);
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
    }
  }

  Future<void> resendVerification(String email) async {
    try {
      await _resendVerification(email);
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading<AuthUserEntity?>();
    try {
      final user = await _login(email, password);
      state = AsyncData<AuthUserEntity?>(user);
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
    }
  }

  /// Signs in with Google using the authorization code flow.
  ///
  /// Returns one of three outcomes via [GoogleSignInOutcome]:
  ///   - [GoogleSignInOutcome.success] → user authenticated, navigate to home.
  ///   - [GoogleSignInOutcome.cancelled] → user dismissed dialog, do nothing.
  ///   - [GoogleSignInOutcome.requiresLinking] → show linking screen.
  ///     Access [pendingLinkingToken] and [pendingLinkingEmail] for the UI.
  ///
  /// The authorization code expires in ~60 seconds — this method
  /// calls the backend immediately after receiving it from Google.
  Future<GoogleSignInOutcome> loginWithGoogle() async {
    try {
      final result = await _googleSignInService.signIn();
      if (result == null) return GoogleSignInOutcome.cancelled;

      state = const AsyncLoading<AuthUserEntity?>();

      final user = await _oauthGoogleSignIn(
        authorizationCode: result.authorizationCode,
      );
      state = AsyncData<AuthUserEntity?>(user);
      return GoogleSignInOutcome.success;
    } on GoogleAccountLinkingRequiredFailure catch (e, s) {
      // Scenario 3 — store the linking data, signal UI to show linking screen.
      state = AsyncError<AuthUserEntity?>(e, s);
      return GoogleSignInOutcome.requiresLinking;
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
      return GoogleSignInOutcome.error;
    }
  }

  /// Completes account linking after [loginWithGoogle] returns
  /// [GoogleSignInOutcome.requiresLinking].
  ///
  /// [linkingToken] — from [GoogleAccountLinkingRequiredFailure.linkingToken].
  /// [password] — the user's existing Tunify password.
  Future<void> linkGoogleAccount({
    required String linkingToken,
    required String password,
  }) async {
    state = const AsyncLoading<AuthUserEntity?>();
    try {
      final user = await _linkGoogleAccount(
        linkingToken: linkingToken,
        password: password,
      );
      state = AsyncData<AuthUserEntity?>(user);
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
    }
  }

  Future<void> logout() async {
    await _logout();
    await _googleSignInService.signOut();
    ref.invalidate(listeningHistoryProvider);
    ref.invalidate(playerProvider);
    state = const AsyncData<AuthUserEntity?>(null);
  }

  Future<void> logoutAll() async {
    await _logoutAll();
    await _googleSignInService.signOut();
    ref.invalidate(listeningHistoryProvider);
    ref.invalidate(playerProvider);
    state = const AsyncData<AuthUserEntity?>(null);
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _forgotPassword(email);
    } on ValidationFailure catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
    } catch (_) {
      // Intentionally swallowed — never reveal whether email exists.
    }
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
    bool signoutAll = true,
  }) async {
    state = const AsyncLoading<AuthUserEntity?>();
    try {
      await _resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        signoutAll: signoutAll,
      );
      state = const AsyncData<AuthUserEntity?>(null);
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
    }
  }

  Future<void> deleteAccount({String? password}) async {
    state = const AsyncLoading<AuthUserEntity?>();
    try {
      await _deleteAccount(password: password);
      state = const AsyncData<AuthUserEntity?>(null);
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
    }
  }
}

/// Result of [AuthController.loginWithGoogle].
enum GoogleSignInOutcome {
  /// Scenario 1/2 — user authenticated successfully. Navigate to home.
  success,

  /// User dismissed the Google account picker. Do nothing.
  cancelled,

  /// Scenario 3 — email already registered locally.
  /// Show the account linking screen.
  /// Extract [GoogleAccountLinkingRequiredFailure] from controller state
  /// to get the [linkingToken] and [email].
  requiresLinking,

  /// Unexpected error (network, serverClientId not set, etc.)
  /// Controller state is [AsyncError] with the failure details.
  error,
}
