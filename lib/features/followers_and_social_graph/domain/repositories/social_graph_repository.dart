import '../entities/social_relation_entity.dart';
import '../entities/social_user_entity.dart';

abstract class SocialGraphRepository {
  Future<List<SocialUserEntity>> getFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  });

  Future<List<SocialUserEntity>> getFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  });

  Future<void> followUser(String userId);

  Future<void> unfollowUser(String userId);

  Future<void> blockUser(String userId);

  Future<void> unblockUser(String userId);

  Future<List<SocialUserEntity>> getBlockedUsers({
    int page = 1,
    int limit = 20,
  });

  Future<List<SocialUserEntity>> getSuggestedUsers({
    int page = 1,
    int limit = 20,
    String? genre,
  });

  Future<SocialRelationEntity> getFollowStatus(String userId);

  Future<List<SocialUserEntity>> getMutualFriends({
    required String userId,
    int page = 1,
    int limit = 20,
  });
}
