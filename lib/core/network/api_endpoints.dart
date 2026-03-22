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

  /// OAuth endpoint — confirm exact path with backend team.
  /// Common options: '/auth/google', '/auth/oauth', '/auth/social'
  static const String oauthLogin = '/auth/google';

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

  
  // Playback
static String trackPlayback(String trackId) => '/tracks/$trackId/playback';
static String trackStream(String trackId) => '/tracks/$trackId/stream';
static const String playbackEvents = '/me/playback/events';
static const String playbackContext = '/playback/context';
static const String listeningHistory = '/me/listening-history';
}

//profile
//when time comes to connect real backend
//Reminder for darine:

// Change this: (profile_api.dart)
//static const String _baseUrl = 'https://69b5b11a583f543fbd9c3072.mockapi.io';
// To this:
//static const String _baseUrl = 'http://10.0.2.2:3000/api';

// Change this:
//final userRes = await _dio.get('$_baseUrl/users/1');
// To this:
//final userRes = await _dio.get('$_baseUrl/users/$userId');
// In api_endpoints.dart add:
///////////////////////////////////////////////
