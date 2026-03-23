class ApiEndpoints {
  ApiEndpoints._();

  //static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String baseUrl = 'https://tunify.duckdns.org/api';

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

  // Google OAuth ──────────────────────────────────────────────────────────
  /// POST /auth/google
  /// Body: { "code": "authorization_code" }
  /// Handles new users, returning users, and triggers linking flow.
  static const String oauthGoogle = '/auth/google';

  /// POST /auth/google/link
  /// Body: { "linkingToken": "...", "password": "..." }
  /// Called only when POST /auth/google returns requiresLinking: true.
  static const String oauthGoogleLink = '/auth/google/link';

  // Upload flow
  static String uploadQuota() => '/users/me/upload';
  static String createTrack() => '/tracks';
  static String uploadAudio(String trackId) => '/tracks/$trackId/audio';
  static String replaceAudio(String trackId) =>
      '/tracks/$trackId/audio/replace';
  static String finalizeMetadata(String trackId) => '/tracks/$trackId';
  static String trackStatus(String trackId) => '/tracks/$trackId/status';
  static String trackDetails(String trackId) => '/tracks/$trackId';
  static String updateTrack(String trackId) => '/tracks/$trackId';
  static String deleteTrack(String trackId) => '/tracks/$trackId';

  // Library / uploads management
  static const String myUploads = '/tracks/me';
  static String artistToolsQuota(String userId) =>
      '/users/$userId/artist-tools/upload-minutes';
  static String uploadDetails(String trackId) => '/tracks/$trackId';
  static String deleteUpload(String trackId) => '/tracks/$trackId';
  static String replaceUploadFile(String trackId) =>
      '/tracks/$trackId/audio/replace';

  //Followers
  static String getFollowers(String userId) => '/users/$userId/followers';
  static String getFollowing(String userId) => '/users/$userId/following';
  static String followUser(String userId) => '/users/$userId/follow';
  static String unfollowUser(String userId) => '/users/$userId/unfollow';
  static String blockUser(String userId) => '/users/$userId/block';
  static String unblockUser(String userId) => '/users/$userId/unblock';
  static String getBlockedUsers() => '/users/me/blocked-users';
  static String getSuggestedUsers() => '/users/me/suggested';
  static String getFollowStatus(String userId) =>
      '/users/$userId/follow-status';
  static String getMutualFriends(String userId) =>
      '/users/$userId/mutual-friends';

  // Profile
  static const String getProfile = '/users/me';
  static const String updateProfile = '/users/me/profile';
  static const String getSocialLinks = '/users/me/social-links';
  static const String updateSocialLinks = '/users/me/social-links';
}
