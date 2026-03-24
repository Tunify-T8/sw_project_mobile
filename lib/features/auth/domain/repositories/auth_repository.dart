import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';

/// Abstract contract for all authentication operations.
///
/// The presentation layer depends only on this interface,
/// keeping it decoupled from network or storage details.
abstract class AuthRepository {
  /// Checks whether [email] is already registered.
  ///
  /// Returns `true` if an account exists, `false` if the email is available.
  Future<bool> checkEmail(String email);

  /// Creates a new account. Does NOT return tokens — email must be verified first.
  ///
  /// Throws on validation error (400) or duplicate email/username (409).
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String gender,
    required String dateOfBirth,
  });

  /// Verifies the user's email with the 6-char [token] from their inbox.
  ///
  /// Returns the authenticated [AuthUserEntity] with tokens on success.
  Future<AuthUserEntity> verifyEmail(String email, String token);

  /// Resends the verification email to [email].
  Future<void> resendVerification(String email);

  /// Authenticates the user with [email] and [password].
  ///
  /// Returns [AuthUserEntity] if verified.
  /// Throws [UnverifiedUserFailure] if the account exists but is not verified.
  /// Throws [UnauthorizedFailure] for wrong credentials.
  Future<AuthUserEntity> login(String email, String password);

  /// Signs in with Google using the authorization code flow.
  ///
  /// [authorizationCode] — the serverAuthCode from GoogleSignIn SDK.
  /// Expires in ~60 seconds. Send immediately after receiving it.
  ///
  /// Three possible outcomes:
  ///   1. New Google user → returns [AuthUserEntity], session saved.
  ///   2. Returning Google user → returns [AuthUserEntity], session saved.
  ///   3. Email already registered locally → throws
  ///      [GoogleAccountLinkingRequiredFailure] containing the linkingToken.
  ///      UI must show the linking screen.
  Future<AuthUserEntity> oauthGoogleSignIn({required String authorizationCode});

  /// Links a Google account to an existing local Tunify account.
  ///
  /// Called only after [oauthGoogleSignIn] throws
  /// [GoogleAccountLinkingRequiredFailure].
  ///
  /// [linkingToken] — from the failure object. Expires in 10 minutes.
  /// [password] — the user's existing Tunify password.
  ///
  /// On success returns [AuthUserEntity] and saves the session.
  /// Google is permanently linked — user can log in with either method.
  Future<AuthUserEntity> linkGoogleAccount({
    required String linkingToken,
    required String password,
  });

  /// Signs out the current device by revoking the stored refresh token.
  Future<void> signOut();

  /// Signs out all devices by revoking all refresh tokens.
  Future<void> signOutAll();

  /// Sends a password reset email to [email].
  Future<void> forgotPassword(String email);

  /// Resets the password using the 6-char [token] from the reset email.
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
    bool signoutAll = true,
  });

  /// Soft-deletes the authenticated user's account.
  ///
  /// [password] is required for local accounts.
  Future<void> deleteAccount({String? password});
}
