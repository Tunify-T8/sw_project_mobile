import 'dart:async';

class MockSocialGraphService {
  Future<List<Map<String, dynamic>>> getFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return List.generate(limit, (index) {
      final number = ((page - 1) * limit) + index + 1;

      return {
        'id': 'follower_$number',
        'username': 'follower_user_$number',
        'avatarUrl': null,
        'location': number.isEven ? 'Cairo, Egypt' : 'Alexandria, Egypt',
        'isFollowing': number.isEven,
        'isVerified': number % 3 == 0,
        'isBlocked': false,
        'followersCount': 100 + number,
        'followingCount': 50 + number,
      };
    });
  }

  Future<List<Map<String, dynamic>>> getFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return List.generate(limit, (index) {
      final number = ((page - 1) * limit) + index + 1;

      return {
        'id': 'following_$number',
        'username': 'following_user_$number',
        'avatarUrl': null,
        'location': number.isEven ? 'Giza, Egypt' : 'Mansoura, Egypt',
        'isFollowing': true,
        'isVerified': number % 3 == 0,
        'isNotificationEnabled': number.isEven,
        'isBlocked': false,
        'followersCount': 200 + number,
        'followingCount': 80 + number,
      };
    });
  }

  Future<void> followUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> unfollowUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> blockUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> unblockUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<Map<String, dynamic>>> getBlockedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return List.generate(limit, (index) {
      final number = ((page - 1) * limit) + index + 1;

      return {
        'id': 'blocked_$number',
        'username': 'blocked_user_$number',
        'avatarUrl': null,
        'location': number.isEven ? 'Tanta, Egypt' : 'Aswan, Egypt',
        'isFollowing': false,
        'isVerified': false,
        'isBlocked': true,
        'followersCount': 20 + number,
        'followingCount': 10 + number,
      };
    });
  }

  Future<List<Map<String, dynamic>>> getSuggestedUsers({
    int page = 1,
    int limit = 20,
    String? genre,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return List.generate(limit, (index) {
      final number = ((page - 1) * limit) + index + 1;

      return {
        'id': 'suggested_$number',
        'username': 'suggested_user_$number',
        'avatarUrl': null,
        'coverUrl': null,
        'location': number.isEven ? 'Dubai, UAE' : 'Beirut, Lebanon',
        'userType': number.isEven ? 'ARTIST' : 'LISTENER',
        'mutualFollowersCount': number % 8,
        'tracksUploadedCount': number * 2,
        'followersCount': 100 + number,
        'followingCount': 50 + number,
        'isVerified': number % 4 == 0,
        'isFollowing': false,
        'isBlocked': false,
        'genre': ?genre,
      };
    });
  }

  Future<Map<String, dynamic>> getFollowStatus({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final isFollowedBy = userId.hashCode.isEven;

    return {
      'isFollowing': true,
      'isFollowedBy': isFollowedBy,
      'isMutual': isFollowedBy,
      'isBlocked': false,
    };
  }

  Future<List<Map<String, dynamic>>> getMutualFriends({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return List.generate(limit, (index) {
      final number = ((page - 1) * limit) + index + 1;

      return {
        'id': 'mutual_$number',
        'username': 'mutual_friend_$number',
        'avatarUrl': null,
        'location': number.isEven ? 'Amman, Jordan' : 'Riyadh, Saudi Arabia',
        'isFollowing': true,
        'isVerified': number % 5 == 0,
        'isBlocked': false,
        'mutualFollowersCount': 3 + (number % 7),
      };
    });
  }
}
