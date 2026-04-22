/// Auth feature — main provider barrel + [AuthController].
///
/// ── WHAT THIS FILE CONTAINS ──────────────────────────────────────────────────
///   1. [authControllerProvider] — the single Riverpod entry point that screens
///      and widgets use to read auth state and call auth operations.
///   2. [AuthController] — the Notifier that orchestrates all auth use cases
///      and manages the global [AsyncValue<AuthUserEntity?>] state.
///   3. [GoogleSignInOutcome] — the return type of [AuthController.loginWithGoogle].
///
/// ── WHAT MOVED OUT ───────────────────────────────────────────────────────────
///   - Infrastructure providers  → `auth_infrastructure_providers.dart`
///   - Repository provider       → `auth_repository_provider.dart`
///   - Use-case providers        → `auth_use_case_providers.dart`
///
/// ── RE-EXPORTS ───────────────────────────────────────────────────────────────
/// All split files are re-exported here so existing imports of
/// `auth_provider.dart` continue to work without modification.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/core/storage/token_storage.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/data/services/google_sign_in_service.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_provider.dart';
import 'auth_infrastructure_providers.dart';
import 'auth_repository_provider.dart';
import 'auth_use_case_providers.dart';

// Re-export split files so callers that import only `auth_provider.dart`
// still have access to every provider they need.
export 'auth_infrastructure_providers.dart';
export 'auth_repository_provider.dart';
export 'auth_use_case_providers.dart';

// ─── Controller provider ──────────────────────────────────────────────────────

/// The global auth controller provider.
///
/// Screens and widgets interact with authentication exclusively through this
/// provider:
///   - `ref.watch(authControllerProvider)` — reactive [AsyncValue<AuthUserEntity?>] state.
///   - `ref.read(authControllerProvider.notifier)` — call auth operations.
///
/// State lifecycle:
///   - `AsyncData(null)`  — signed out (initial).
///   - `AsyncLoading()`   — an operation is in progress.
///   - `AsyncData(user)`  — authenticated; [AuthUserEntity] holds the user.
///   - `AsyncError(e, s)` — the last operation failed; [e] is a [Failure].
final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<AuthUserEntity?>>(
      AuthController.new,
    );

// ─── Controller ───────────────────────────────────────────────────────────────

/// Orchestrates all Module 1 authentication operations.
///
/// Each method delegates to a use case and updates [state] accordingly.
/// Screens listen to [state] via `ref.listen` for side-effects (navigation,
/// snackbars) and read `ref.watch` for loading spinners.
///
/// Never construct this directly — use [authControllerProvider].
class AuthController extends Notifier<AsyncValue<AuthUserEntity?>> {
  // ── Use case accessors ──────────────────────────────────────────────────
  // Lazy-read from the Riverpod container so the controller is testable:
  // tests override the provider, not the controller constructor.

  /// Checks whether an email is already registered (no state change).
  // ignore: library_private_types_in_public_api
  get _checkEmail => ref.read(checkEmailUseCaseProvider);

  /// Registers a new account.
  get _register => ref.read(registerUseCaseProvider);

  /// Verifies email with OTP token.
  get _verifyEmail => ref.read(verifyEmailUseCaseProvider);

  /// Re-sends the verification email.
  get _resendVerification => ref.read(resendVerificationUseCaseProvider);

  /// Signs in with email + password.
  get _login => ref.read(loginUseCaseProvider);

  /// Signs in with Google authorization code.
  get _oauthGoogleSignIn => ref.read(oauthGoogleSignInUseCaseProvider);

  /// Links a Google account to an existing local account.
  get _linkGoogleAccount => ref.read(linkGoogleAccountUseCaseProvider);

  /// Signs out the current device.
  get _logout => ref.read(logoutUseCaseProvider);

  /// Signs out all devices.
  get _logoutAll => ref.read(logoutAllUseCaseProvider);

  /// Sends a password reset email.
  get _forgotPassword => ref.read(forgotPasswordUseCaseProvider);

  /// Resets the password with a 6-char token.
  get _resetPassword => ref.read(resetPasswordUseCaseProvider);

  /// Deletes the authenticated account.
  get _deleteAccount => ref.read(deleteAccountUseCaseProvider);

  /// Google Sign-In SDK wrapper.
  GoogleSignInService get _googleSignInService =>
      ref.read(googleSignInServiceProvider);

  /// Secure token/session storage.
  TokenStorage get _tokenStorage => ref.read(tokenStorageProvider);

  // ── Notifier lifecycle ──────────────────────────────────────────────────

  @override
  AsyncValue<AuthUserEntity?> build() => const AsyncData<AuthUserEntity?>(null);

  // ── Session helpers ─────────────────────────────────────────────────────

  /// Reads the persisted user from secure storage and updates [state].
  ///
  /// Called by [AuthProtectedScreen] on every protected-route mount to
  /// re-hydrate the session after a hot-restart or cold launch.
  /// Returns the restored [AuthUserEntity], or `null` if no session exists.
  Future<AuthUserEntity?> restoreSession() async {
    final user = await _tokenStorage.getUser();
    state = AsyncData<AuthUserEntity?>(user);
    return user;
  }

  /// Updates the in-memory and persisted user identity after a profile edit.
  ///
  /// Called by the profile feature when the user changes their display name
  /// or avatar so the controller state stays consistent with the profile data.
  ///
  /// [username] — the new display name / username.
  /// [avatarUrl] — the new avatar URL, or `null` to clear it.
  ///
  /// Returns the updated [AuthUserEntity], or `null` if no session was found.
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

  // ── Auth operations ─────────────────────────────────────────────────────

  /// Checks whether [email] is already registered.
  ///
  /// Does not change loading state — purely returns a bool.
  /// On failure sets state to [AsyncError] and returns `false`.
  Future<bool> checkEmail(String email) async {
    try {
      return await _checkEmail(email);
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
      return false;
    }
  }

  /// Registers a new account with the given credentials.
  ///
  /// On success: state → `AsyncData(null)`. Navigation to verify-email is
  /// handled by the screen via `ref.listen`.
  /// On failure: state → `AsyncError(failure)`. Screen shows snackbar.
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

  /// Verifies the user's email with the 6-character OTP [token].
  ///
  /// On success: state → `AsyncData(user)`. Navigation to home is handled
  /// by the screen.
  /// On failure (wrong/expired token): state → `AsyncError(UnauthorizedFailure)`.
  Future<void> verifyEmail(String email, String token) async {
    state = const AsyncLoading<AuthUserEntity?>();
    try {
      final user = await _verifyEmail(email, token);
      state = AsyncData<AuthUserEntity?>(user);
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
    }
  }

  /// Re-sends the 6-character verification code to [email].
  ///
  /// Does not update loading state — the screen shows its own spinner.
  /// On failure sets state to [AsyncError] but the screen can still recover.
  Future<void> resendVerification(String email) async {
    try {
      await _resendVerification(email);
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
    }
  }

  /// Signs in with [email] and [password].
  ///
  /// On success: state → `AsyncData(user)`.
  /// On unverified: state → `AsyncError(UnverifiedUserFailure)`.
  /// On wrong password: state → `AsyncError(UnauthorizedFailure)`.
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
  /// Returns a [GoogleSignInOutcome] so the screen knows which action to take:
  ///   - [GoogleSignInOutcome.success]         → navigate to home.
  ///   - [GoogleSignInOutcome.cancelled]        → do nothing.
  ///   - [GoogleSignInOutcome.requiresLinking]  → show linking screen;
  ///     read [GoogleAccountLinkingRequiredFailure] from controller state.
  ///   - [GoogleSignInOutcome.error]            → show error snackbar.
  ///
  /// The authorization code expires in ~60 seconds — this method sends it
  /// to the backend immediately after receiving it from Google.
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
      state = AsyncError<AuthUserEntity?>(e, s);
      return GoogleSignInOutcome.requiresLinking;
    } catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
      return GoogleSignInOutcome.error;
    }
  }

  /// Links a Google account to an existing local account.
  ///
  /// Called only after [loginWithGoogle] returns [GoogleSignInOutcome.requiresLinking].
  ///
  /// [linkingToken] — from [GoogleAccountLinkingRequiredFailure.linkingToken].
  ///                  Expires in 10 minutes.
  /// [password]     — the user's existing local password.
  ///
  /// On success: state → `AsyncData(user)`. Navigation handled by the screen.
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

  /// Signs out the current device.
  ///
  /// Revokes the stored refresh token, clears all local session data,
  /// invalidates the player and listening history, and resets state to
  /// `AsyncData(null)`.
  Future<void> logout() async {
    await _logout();
    await _googleSignInService.signOut();
    ref.invalidate(listeningHistoryProvider);
    ref.invalidate(playerProvider);
    state = const AsyncData<AuthUserEntity?>(null);
  }

  /// Signs out all devices.
  ///
  /// Same as [logout] but revokes every refresh token for the account, not
  /// just the current one.
  Future<void> logoutAll() async {
    await _logoutAll();
    await _googleSignInService.signOut();
    ref.invalidate(listeningHistoryProvider);
    ref.invalidate(playerProvider);
    state = const AsyncData<AuthUserEntity?>(null);
  }

  /// Sends a password reset code to [email].
  ///
  /// Never reveals whether the email exists (API security spec) — always
  /// navigates to [ResetPasswordScreen] regardless of outcome.
  /// Only propagates [ValidationFailure] (malformed email) to the UI.
  Future<void> forgotPassword(String email) async {
    try {
      await _forgotPassword(email);
    } on ValidationFailure catch (e, s) {
      state = AsyncError<AuthUserEntity?>(e, s);
    } catch (_) {
      // Intentionally swallowed — do not reveal whether the email exists.
    }
  }

  /// Resets the password using the 6-char [token] from the reset email.
  ///
  /// [signoutAll] — when `true` (default), all active sessions are revoked
  /// so an attacker who triggered the reset cannot stay logged in elsewhere.
  ///
  /// On success: state → `AsyncData(null)`.
  /// On expired/invalid token: state → `AsyncError(UnauthorizedFailure)`.
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

  /// Soft-deletes the authenticated account.
  ///
  /// [password] is required for local (email/password) accounts.
  /// Omit for accounts that only have a linked Google identity.
  ///
  /// On success: state → `AsyncData(null)`. Navigation to landing handled
  /// by the screen.
  /// On wrong password: state → `AsyncError(UnauthorizedFailure)`.
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

// ─── Supporting enum ──────────────────────────────────────────────────────────

/// The four possible outcomes of [AuthController.loginWithGoogle].
///
/// The screen switches on this value to decide what to do after
/// [AuthController.loginWithGoogle] returns.
enum GoogleSignInOutcome {
  /// Scenario 1/2 — user authenticated successfully.
  /// Navigate to home. Controller state is `AsyncData(user)`.
  success,

  /// User dismissed the Google account picker without signing in.
  /// Do nothing. Controller state is unchanged.
  cancelled,

  /// Scenario 3 — the Google email is already registered as a local account.
  /// Show the account-linking screen.
  /// Read [GoogleAccountLinkingRequiredFailure] from controller state to
  /// get the [linkingToken] and [email].
  requiresLinking,

  /// An unexpected error occurred (network issue, misconfigured serverClientId, etc.).
  /// Show an error snackbar. Controller state is `AsyncError`.
  error,
}
