import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/core/network/dio_client.dart';
import 'package:software_project/core/storage/token_storage.dart';
import 'package:software_project/features/auth/data/api/auth_api.dart';
import 'package:software_project/features/auth/data/repository/auth_repository_impl.dart';
import 'package:software_project/features/auth/data/services/google_sign_in_service.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:software_project/features/auth/domain/usecases/check_email_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/login_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/logout_all_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/logout_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/register_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:software_project/features/auth/data/mock/mock_auth_config.dart';
import 'package:software_project/features/auth/data/mock/mock_auth_service.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────

final tokenStorageProvider = Provider<TokenStorage>(
  (_) => const TokenStorage(),
);

final authApiProvider = Provider<AuthApi>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  return AuthApi(DioClient.create(tokenStorage));
});

final googleSignInServiceProvider = Provider<GoogleSignInService>(
  (_) => GoogleSignInService(),
);

// ─── Repository ───────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authApiProvider),
    ref.read(tokenStorageProvider),
  );
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

/// Provides and manages the [AuthController] state machine.
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthUserEntity?>>((ref) {
      return AuthController(
        checkEmail: ref.read(checkEmailUseCaseProvider),
        register: ref.read(registerUseCaseProvider),
        verifyEmail: ref.read(verifyEmailUseCaseProvider),
        resendVerification: ref.read(resendVerificationUseCaseProvider),
        login: ref.read(loginUseCaseProvider),
        logout: ref.read(logoutUseCaseProvider),
        logoutAll: ref.read(logoutAllUseCaseProvider),
        forgotPassword: ref.read(forgotPasswordUseCaseProvider),
        resetPassword: ref.read(resetPasswordUseCaseProvider),
        deleteAccount: ref.read(deleteAccountUseCaseProvider),
        googleSignInService: ref.read(googleSignInServiceProvider),
      );
    });

/// Manages authentication state for the entire app.
///
/// State is [AsyncValue<AuthUserEntity?>]:
/// - `data(null)`  → unauthenticated
/// - `data(user)`  → authenticated
/// - `loading()`   → operation in progress
/// - `error(e, s)` → last operation failed with a [Failure]
class AuthController extends StateNotifier<AsyncValue<AuthUserEntity?>> {
  final CheckEmailUseCase _checkEmail;
  final RegisterUseCase _register;
  final VerifyEmailUseCase _verifyEmail;
  final ResendVerificationUseCase _resendVerification;
  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final LogoutAllUseCase _logoutAll;
  final ForgotPasswordUseCase _forgotPassword;
  final ResetPasswordUseCase _resetPassword;
  final DeleteAccountUseCase _deleteAccount;
  final GoogleSignInService _googleSignInService;

  AuthController({
    required CheckEmailUseCase checkEmail,
    required RegisterUseCase register,
    required VerifyEmailUseCase verifyEmail,
    required ResendVerificationUseCase resendVerification,
    required LoginUseCase login,
    required LogoutUseCase logout,
    required LogoutAllUseCase logoutAll,
    required ForgotPasswordUseCase forgotPassword,
    required ResetPasswordUseCase resetPassword,
    required DeleteAccountUseCase deleteAccount,
    required GoogleSignInService googleSignInService,
  }) : _checkEmail = checkEmail,
       _register = register,
       _verifyEmail = verifyEmail,
       _resendVerification = resendVerification,
       _login = login,
       _logout = logout,
       _logoutAll = logoutAll,
       _forgotPassword = forgotPassword,
       _resetPassword = resetPassword,
       _deleteAccount = deleteAccount,
       _googleSignInService = googleSignInService,
       super(const AsyncValue.data(null));

  /// Checks if [email] is registered. Returns true if exists.
  ///
  /// Uses [MockAuthService] when [MockAuthConfig.useMock] is true.
  /// Change [MockAuthConfig.emailScenario] to test different outcomes.
  Future<bool> checkEmail(String email) async {
    if (MockAuthConfig.useMock) {
      return MockAuthService.checkEmail(email);
    }
    try {
      return await _checkEmail(email);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }

  /// Registers a new user. Navigates to verify-email after success.
  ///
  /// Uses [MockAuthService] when [MockAuthConfig.useMock] is true.
  /// Change [MockAuthConfig.registerScenario] to test different outcomes.
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) async {
    state = const AsyncValue.loading();
    try {
      if (MockAuthConfig.useMock) {
        await MockAuthService.register();
      } else {
        await _register(
          email: email,
          username: username,
          password: password,
          gender: gender,
          dateOfBirth: dateOfBirth,
        );
      }
      // Registration succeeds but no user yet — return null data
      // to signal "go to verify-email" in the UI.
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Verifies email with [token]. Sets state to authenticated user on success.
  ///
  /// Uses [MockAuthService] when [MockAuthConfig.useMock] is true.
  /// Change [MockAuthConfig.verifyScenario] to test different outcomes.
  Future<void> verifyEmail(String email, String token) async {
    state = const AsyncValue.loading();
    try {
      final user = MockAuthConfig.useMock
          ? await MockAuthService.verifyEmail()
          : await _verifyEmail(email, token);
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Resends the verification email.
  Future<void> resendVerification(String email) async {
    try {
      await _resendVerification(email);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Logs in with [email] and [password].
  ///
  /// Uses [MockAuthService] when [MockAuthConfig.useMock] is true.
  /// Change [MockAuthConfig.loginScenario] to test different outcomes.
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = MockAuthConfig.useMock
          ? await MockAuthService.login(email, password)
          : await _login(email, password);
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Logs in via Google OAuth.
  /// Returns false if the user cancelled the Google dialog.
  Future<bool> loginWithGoogle() async {
    try {
      final result = await _googleSignInService.signIn();
      if (result == null) return false;
      // TODO: Call oauthLogin endpoint once backend adds POST /auth/google.
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }

  /// Signs out the current device.
  ///
  /// Uses [MockAuthService] when [MockAuthConfig.useMock] is true.
  Future<void> logout() async {
    if (MockAuthConfig.useMock) {
      await MockAuthService.logout();
    } else {
      await _logout();
    }
    await _googleSignInService.signOut();
    state = const AsyncValue.data(null);
  }

  /// Signs out all devices.
  Future<void> logoutAll() async {
    await _logoutAll();
    await _googleSignInService.signOut();
    state = const AsyncValue.data(null);
  }

  /// Sends a password reset email.
  ///
  /// Per the Tunify API spec the UI always navigates to check-your-email
  /// regardless of the outcome — never reveal whether an address exists.
  /// Uses [MockAuthService] when [MockAuthConfig.useMock] is true.
  Future<void> forgotPassword(String email) async {
    try {
      if (MockAuthConfig.useMock) {
        await MockAuthService.forgotPassword(email);
      } else {
        await _forgotPassword(email);
      }
    } catch (_) {
      // Intentionally swallowed — UI always shows the check-email screen.
    }
  }

  /// Resets the password using the token from the reset email.
  ///
  /// Uses [MockAuthService] when [MockAuthConfig.useMock] is true.
  /// Change [MockAuthConfig.resetScenario] to test different outcomes.
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
    bool signoutAll = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      if (MockAuthConfig.useMock) {
        await MockAuthService.resetPassword();
      } else {
        await _resetPassword(
          email: email,
          token: token,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
          signoutAll: signoutAll,
        );
      }
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Permanently deletes the authenticated user's account.
  ///
  /// Uses [MockAuthService] when [MockAuthConfig.useMock] is true.
  /// Change [MockAuthConfig.deleteScenario] to test different outcomes.
  Future<void> deleteAccount({String? password}) async {
    state = const AsyncValue.loading();
    try {
      if (MockAuthConfig.useMock) {
        await MockAuthService.deleteAccount();
      } else {
        await _deleteAccount(password: password);
      }
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
