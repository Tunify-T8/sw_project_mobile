class ApiEndpoints {
  ApiEndpoints._();

  //static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String baseUrl = 'https://tunify.duckdns.org/api';

  /// Base URL used for shareable links (no /api suffix).
  static const String shareBaseUrl = 'https://tunify.duckdns.org';

  /// Builds a shareable track URL.
  /// Private tracks include [privateToken] as a query parameter.
  static String shareTrackUrl(String trackId, {String? privateToken}) {
    final base = Uri.parse(
      shareBaseUrl,
    ).replace(pathSegments: ['tracks', trackId]);
    if (privateToken == null || privateToken.trim().isEmpty) {
      return base.toString();
    }
    return base
        .replace(queryParameters: {'privateToken': privateToken})
        .toString();
  }

  /// Builds a shareable profile URL.
  static String shareProfileUrl(String username) =>
      '$shareBaseUrl/users/$username';

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

  // Followers
  static String followUser(String userId) => '/users/$userId/follow';
  static String unfollowUser(String userId) => '/users/$userId/unfollow';
  static String blockUser(String userId) => '/users/$userId/block';
  static String unblockUser(String userId) => '/users/$userId/unblock';
  static String getFollowStatus(String userId) =>
      '/users/$userId/follow-status';
  static String getUserFollowers(String userId) => '/users/$userId/followers';
  static String getUserFollowing(String userId) => '/users/$userId/following';

  static const String getMyFollowers = '/users/me/followers';
  static const String getMyFollowing = '/users/me/following';
  static const String getBlockedUsers = '/users/me/blocked-users';
  static const String getTrueFriends = '/users/me/true-friends';
  static const String getSuggestedUsers = '/users/me/suggested';
  static const String getSuggestedArtists = '/users/me/suggested/artists';

  // Profile
  static const String getProfile = '/users/me';
  static String getUserProfile(String userIdOrUsername) =>
      '/users/$userIdOrUsername';
  // Public tracks for any user — used to build the "Next up" queue from the
  // playing artist's catalog without needing the current user to have played
  // those tracks before. Mirrors the /tracks/me response shape.
  static String getUserTracks(String userId) => '/users/$userId/tracks';
  static const String updateProfile = '/users/me/profile';
  static const String getSocialLinks = '/users/me/social-links';
  static const String updateSocialLinks = '/users/me/social-links';

  // Playback
  static String trackPlayback(String trackId) => '/tracks/$trackId/playback';
  static String trackStream(String trackId) => '/tracks/$trackId/stream';
  static String trackPlayed(String trackId) => '/tracks/$trackId/played';
  static String trackDownload(String trackId) => '/tracks/$trackId/download';

  /// Older contract endpoint kept only as a compatibility fallback.
  static const String playbackEvents = '/me/playback/events';

  /// Current backend contract (v1.1.0).
  static const String listeningHistory = '/tracks/me/listening-history';

  /// Older contract endpoint kept only as a compatibility fallback.
  static const String legacyListeningHistory = '/me/listening-history';

  /// Current backend contract (v1.1.0).
  static const String clearListeningHistory = '/tracks/me/listening-history';

  /// Older contract endpoint kept only as a compatibility fallback.
  static const String legacyClearListeningHistory = '/me/listening-history';

  /// Batch-reports plays that occurred while the device was offline.
  /// Body: `{ "plays": [{ "trackId", "playedAt", "completed" }] }`
  static const String batchPlays = '/tracks/plays/batch';

  /// Current backend contract (v1.1.0).
  static const String playbackContext = '/tracks/playback-context';

  /// Older contract endpoint kept only as a compatibility fallback.
  static const String legacyPlaybackContext = '/playback/context';

  // Engagement & Social Interactions
  static String trackEngagement(String trackId) =>
      '/tracks/$trackId/engagement';
  static String likeTrack(String trackId) => '/tracks/$trackId/like';
  static String repostTrack(String trackId) => '/tracks/$trackId/repost';
  static String trackComments(String trackId) => '/tracks/$trackId/comments';
  static String trackLikers(String trackId) => '/tracks/$trackId/likes';
  static String trackReposters(String trackId) => '/tracks/$trackId/reposts';
  static String deleteComment(String commentId) => '/comments/$commentId';
  static String commentReplies(String commentId) =>
      '/comments/$commentId/replies';
  static String likeComment(String commentId) => '/comments/$commentId/like';
  static const String myLikedTracks = '/users/me/liked-tracks';
  static const String myReposts = '/users/me/reposts';
  static String userReposts(String userId) => '/users/$userId/reposts';

  // Feed - Search - Discovery
  static const String getFollowingFeed = '/feed';
  static const String getDiscover = '/discover';
  static const String getTrending = '/feed/trending';
  //static const String getSuggestedArtists = '/feed/suggested-artists';
  static const String search = '/search';
  static const String searchTracks = '/search/tracks';
  static const String searchCollections = '/search/collections';
  static const String searchPeople = '/search/people';
  static const String searchAutocomplete = '/search/autocomplete';

  //Premuim
  static const String getSubscriptionPlans = '/subscriptions/plans';
  static const String getCurrentSubscription = '/subscriptions/me';
  static const String subscribe = '/subscriptions/subscribe';
  static const String cancelSubscription = '/subscriptions/cancel';

  //  Collections & Playlists
  static const String collections = '/collections';
  static const String myCollections = '/collections/me';

  static String collectionByToken(String token) => '/collections/token/$token';

  static String collectionById(String id) => '/collections/$id';

  static String collectionTracks(String id) => '/collections/$id/tracks';
  static String collectionTracksAdd(String id) => '/collections/$id/tracks/add';
  static String collectionTracksRemove(String id) =>
      '/collections/$id/tracks/remove';
  static String collectionTracksReorder(String id) =>
      '/collections/$id/tracks/reorder';

  static String collectionLike(String id) => '/collections/$id/like';
  static String collectionEmbed(String id) => '/collections/$id/embed';
  static String collectionShare(String id) => '/collections/$id/share';
  static String collectionShareReset(String id) =>
      '/collections/$id/share/reset';

  static String userCollections(String username) =>
      '/users/$username/collections';
  static String userAlbums(String username) => '/users/$username/albums';
  static String userPlaylists(String username) => '/users/$username/playlists';
}
