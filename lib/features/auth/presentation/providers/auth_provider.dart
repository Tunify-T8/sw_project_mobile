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
import 'package:software_project/features/auth/domain/usecases/login_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/logout_all_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/logout_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/register_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/verify_email_usecase.dart';

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
  // ── Single mock/real switch ───────────────────────────────────────────────
  // Change MockAuthConfig.useMock to false when the backend is ready.
  // Nothing else in the codebase needs to change.
  if (MockAuthConfig.useMock) {
    return const MockAuthRepository();
  }
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
///
/// NOTE on the mock system (#11): The current mock interception points live in
/// individual screens (EmailEntryScreen, TellUsMoreScreen) which is an
/// architectural violation (presentation importing data/mock). The correct
/// design would register a FakeMockAuthRepository as the authRepositoryProvider
/// override when MockAuthConfig.useMock == true, so screens never need to
/// know about mocks. This is the recommended next refactor but is left for
/// when the real backend is integrated, as it requires reworking how
/// ProviderScope overrides are set up in bootstrap.dart.
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

  /// Returns true if [email] is already registered.
  Future<bool> checkEmail(String email) async {
    try {
      return await _checkEmail(email);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }

  /// Creates a new account. State becomes data(null) on success —
  /// the user must verify their email before a session is started.
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String gender,
    required String dateOfBirth,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _register(
        email: email,
        username: username,
        password: password,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Verifies the email with [token]. Sets state to the authenticated user.
  Future<void> verifyEmail(String email, String token) async {
    state = const AsyncValue.loading();
    try {
      final user = await _verifyEmail(email, token);
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

  /// Authenticates with email and password.
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _login(email, password);
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Initiates Google OAuth. Returns false if the user cancels.
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

  /// Signs out the current device and resets state.
  Future<void> logout() async {
    await _logout();
    await _googleSignInService.signOut();
    state = const AsyncValue.data(null);
  }

  /// Signs out all devices and resets state.
  Future<void> logoutAll() async {
    await _logoutAll();
    await _googleSignInService.signOut();
    state = const AsyncValue.data(null);
  }

  /// Sends a password reset email.
  ///
  /// Validation errors (400) are surfaced so the UI can display them safely.
  /// All other errors are swallowed to avoid revealing whether the address
  /// exists on the backend.
  Future<void> forgotPassword(String email) async {
    try {
      await _forgotPassword(email);
    } on ValidationFailure catch (e, s) {
      // A 400 means the email format was rejected by the server — this is
      // safe to surface since it reveals nothing about whether the address
      // is registered.
      state = AsyncValue.error(e, s);
    } catch (_) {
      // All other errors (404, network, server) are swallowed intentionally.
    }
  }

  /// Resets the password using the token from the reset email.
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
    bool signoutAll = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        signoutAll: signoutAll,
      );
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Permanently deletes the account and clears state.
  Future<void> deleteAccount({String? password}) async {
    state = const AsyncValue.loading();
    try {
      await _deleteAccount(password: password);
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
