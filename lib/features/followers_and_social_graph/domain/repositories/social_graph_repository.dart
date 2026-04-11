import '../entities/social_relation_entity.dart';
import '../entities/social_user_entity.dart';

abstract class SocialGraphRepository {
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
  Future<SocialRelationEntity> getFollowStatus(String userId);

  Future<List<SocialUserEntity>> getUserFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  });
  Future<List<SocialUserEntity>> getUserFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  });

  Future<List<SocialUserEntity>> getMyFollowers({int page = 1, int limit = 20});
  Future<List<SocialUserEntity>> getMyFollowing({int page = 1, int limit = 20});
  Future<List<SocialUserEntity>> getBlockedUsers({
    int page = 1,
    int limit = 20,
  });
  Future<List<SocialUserEntity>> getTrueFriends({int page = 1, int limit = 20});

  Future<List<SocialUserEntity>> getSuggestedUsers({
    int page = 1,
    int limit = 20,
  });
  Future<List<SocialUserEntity>> getSuggestedArtists({
    int page = 1,
    int limit = 20,
  });
}
