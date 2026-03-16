class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Auth
  static const String checkEmail = '/auth/check-email';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String signOut = '/auth/signout';
  static const String signOutAll = '/auth/signout-all';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String deleteAccount = '/auth/delete-account';

  // Upload flow
  static String uploadQuota() => '/users/me/upload';
  static String createTrack() => '/tracks';
  static String uploadAudio(String trackId) => '/tracks/$trackId/audio';
  static String replaceAudio(String trackId) => '/tracks/$trackId/audio/replace';
  static String finalizeMetadata(String trackId) => '/tracks/$trackId';
  static String trackStatus(String trackId) => '/tracks/$trackId/status';
  static String trackDetails(String trackId) => '/tracks/$trackId';
  static String updateTrack(String trackId) => '/tracks/$trackId';
  static String deleteTrack(String trackId) => '/tracks/$trackId';

  // Library / uploads management
  static const String myUploads = '/me/uploads';
  static String artistToolsQuota([String userId = 'me']) =>
      '/users/$userId/artist-tools/upload-minutes';
  static String uploadDetails(String trackId) => '/tracks/$trackId';
  static String deleteUpload(String trackId) => '/tracks/$trackId';
  static String replaceUploadFile(String trackId) => '/tracks/$trackId/audio/replace';
}
