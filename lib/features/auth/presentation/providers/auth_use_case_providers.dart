/// Riverpod providers for every Module 1 authentication use case.
///
/// ── RESPONSIBILITY ───────────────────────────────────────────────────────────
/// Creates and exposes one [Provider] per use case, each depending on
/// [authRepositoryProvider]. The [AuthController] reads these via
/// `ref.read(xUseCaseProvider)` — it never instantiates use cases directly.
///
/// ── WHY SEPARATE ─────────────────────────────────────────────────────────────
/// Previously all 13 use-case providers were in `auth_provider.dart` alongside
/// the controller, infrastructure providers, and repository provider — a clear
/// SRP violation. Isolating them here means:
///   - Adding a new use case only touches this file.
///   - Testing a use case provider only requires overriding
///     [authRepositoryProvider], not the entire auth graph.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'auth_repository_provider.dart';

// ── Registration & verification ───────────────────────────────────────────────

/// Checks whether an email address is already registered.
/// Used by [EmailEntryScreen] to decide which flow to open.
final checkEmailUseCaseProvider = Provider<CheckEmailUseCase>(
  (ref) => CheckEmailUseCase(ref.read(authRepositoryProvider)),
);

/// Creates a new account (email + password + display name + DOB + gender).
/// Does not return tokens — email verification is required before login.
final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.read(authRepositoryProvider)),
);

/// Verifies the user's email using the 6-character OTP from their inbox.
/// Returns [AuthUserEntity] with tokens on success.
final verifyEmailUseCaseProvider = Provider<VerifyEmailUseCase>(
  (ref) => VerifyEmailUseCase(ref.read(authRepositoryProvider)),
);

/// Re-sends the 6-character verification code to the registered email.
final resendVerificationUseCaseProvider = Provider<ResendVerificationUseCase>(
  (ref) => ResendVerificationUseCase(ref.read(authRepositoryProvider)),
);

// ── Sign-in ───────────────────────────────────────────────────────────────────

/// Authenticates a verified user with email + password.
/// Throws [UnverifiedUserFailure] if the account exists but is unverified.
/// Throws [UnauthorizedFailure] for wrong credentials.
final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);

// ── OAuth ─────────────────────────────────────────────────────────────────────

/// Sends a Google authorization code to the backend and signs in.
/// Three outcomes: new user created, returning user authenticated, or
/// email collision requiring account linking.
final oauthGoogleSignInUseCaseProvider = Provider<OAuthGoogleSignInUseCase>(
  (ref) => OAuthGoogleSignInUseCase(ref.read(authRepositoryProvider)),
);

/// Links a Google account to an existing local account after a collision.
/// Requires the short-lived linking token from [OAuthGoogleSignInUseCase].
final linkGoogleAccountUseCaseProvider = Provider<LinkGoogleAccountUseCase>(
  (ref) => LinkGoogleAccountUseCase(ref.read(authRepositoryProvider)),
);

// ── Session management ────────────────────────────────────────────────────────

/// Signs out of the current device by revoking the stored refresh token.
final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.read(authRepositoryProvider)),
);

/// Signs out of all devices by revoking every refresh token for the account.
final logoutAllUseCaseProvider = Provider<LogoutAllUseCase>(
  (ref) => LogoutAllUseCase(ref.read(authRepositoryProvider)),
);

// ── Account recovery ──────────────────────────────────────────────────────────

/// Sends a password reset code to the user's registered email.
/// Always succeeds from the UI's perspective (never reveals whether email exists).
final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>(
  (ref) => ForgotPasswordUseCase(ref.read(authRepositoryProvider)),
);

/// Resets the password using the 6-char token from the reset email.
/// Optionally signs out all sessions after the reset.
final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>(
  (ref) => ResetPasswordUseCase(ref.read(authRepositoryProvider)),
);

// ── Account deletion ──────────────────────────────────────────────────────────

/// Soft-deletes the authenticated account.
/// [password] is required for local accounts; omit for OAuth-only accounts.
final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>(
  (ref) => DeleteAccountUseCase(ref.read(authRepositoryProvider)),
);
