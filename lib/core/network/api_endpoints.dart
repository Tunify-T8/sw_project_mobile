/// Centralized API endpoint paths for the Tunify backend.
///
/// All endpoint strings live here. Never hard-code paths in API classes.
class ApiEndpoints {
  ApiEndpoints._();

  /// Check if an email exists. Returns { exists: bool }.
  static const String checkEmail = '/auth/check-email';

  /// Create a new account. Returns user info only (no tokens until verified).
  static const String register = '/auth/register';

  /// Verify email with 6-char token. Returns tokens + user.
  static const String verifyEmail = '/auth/verify-email';

  /// Resend verification email.
  static const String resendVerification = '/auth/resend-verification';

  /// Login with email + password. Returns tokens if verified.
  static const String login = '/auth/login';

  /// Exchange refresh token for new token pair.
  static const String refreshToken = '/auth/refresh-token';

  /// Revoke refresh token for current device.
  static const String signOut = '/auth/signout';

  /// Revoke all refresh tokens for this user (sign out everywhere).
  static const String signOutAll = '/auth/signout-all';

  /// Request a password reset email.
  static const String forgotPassword = '/auth/forgot-password';

  /// Reset password with 6-char token from email.
  static const String resetPassword = '/auth/reset-password';

  /// Soft-delete the authenticated user's account.
  static const String deleteAccount = '/auth/delete-account';
}
