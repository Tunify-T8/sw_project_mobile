 // so no objects can be created

  // Because if your backend changes a path later, you only fix it in one place.

  // Replace this with your backend URL.
  // Android emulator -> use 10.0.2.2 instead of localhost.
  class ApiEndpoints {
  ApiEndpoints._();

  // Android emulator -> use 10.0.2.2 instead of localhost.
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Module 4 — Upload quota on entering upload flow
  static String uploadQuota() => '/users/me/upload';

  // Module 4 — Create draft track before file upload
  static String createTrack() => '/tracks';

  // Module 4 — Upload audio binary
  static String uploadAudio(String trackId) => '/tracks/$trackId/audio';

  // Module 4 — Premium replace audio
  static String replaceAudio(String trackId) => '/tracks/$trackId/audio/replace';

  // Module 4 — Finalize upload / update metadata
  static String finalizeMetadata(String trackId) => '/tracks/$trackId';

  // Module 4 — Poll processing status
  static String trackStatus(String trackId) => '/tracks/$trackId/status';

  // Module 4 — Get details
  static String trackDetails(String trackId) => '/tracks/$trackId';

  // Module 4 — Edit after upload
  static String updateTrack(String trackId) => '/tracks/$trackId';

  // Module 4 — Delete
  static String deleteTrack(String trackId) => '/tracks/$trackId';
  static const String myUploads = '/me/uploads';
  static const String artistToolsQuota = '/me/uploads/artist-tools';

  static String uploadDetails(String trackId) => '/tracks/$trackId';
  static String deleteUpload(String trackId) => '/tracks/$trackId';
  static String replaceUploadFile(String trackId) =>
      '/tracks/$trackId/replace-file';

}
// We need a shared network layer.

// We should not repeat URL strings in repositories or APIs.

// Module 4 already has a known contract: quota, create track, upload audio, finalize metadata, poll status, details, update, delete.

// Let’s encode that contract as endpoint helpers.

// So this file is really a translation of the API contract into code. /* /// Centralized API endpoint paths for the Tunify backend.
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

















*/
