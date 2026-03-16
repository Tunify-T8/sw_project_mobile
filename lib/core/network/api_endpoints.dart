class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://10.0.2.2:3000/api';

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
}
