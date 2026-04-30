import '../../domain/entities/social_relation_entity.dart';
import '../../domain/entities/social_user_entity.dart';
import '../../domain/repositories/social_graph_repository.dart';
import '../api/social_api.dart';
import '../mappers/social_relation_mapper.dart';
import '../mappers/social_user_mapper.dart';

class SocialGraphRepositoryImpl implements SocialGraphRepository {
  final SocialApi api;

  SocialGraphRepositoryImpl(this.api);

  @override
  Future<void> followUser(String userId) async {
    await api.followUser(userId);
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await api.unfollowUser(userId);
  }

  @override
  Future<void> blockUser(String userId) async {
    await api.blockUser(userId);
  }

  @override
  Future<void> unblockUser(String userId) async {
    await api.unblockUser(userId);
  }

  @override
  Future<SocialRelationEntity> getFollowStatus(String userId) async {
    final dto = await api.getFollowStatus(userId);
    return dto.toEntity(userId);
  }

  @override
  Future<bool> doesUserFollowMe(String otherUserId, String myUserId) async {
    // Page through who the other user follows and check if my id is there.
    // Stops early on the first match. Capped to avoid unbounded paging.
    const pageSize = 100;
    const maxPages = 20;
    for (var page = 1; page <= maxPages; page++) {
      final batch = await api.getUserFollowing(
        userId: otherUserId,
        page: page,
        limit: pageSize,
      );
      if (batch.any((u) => u.id == myUserId)) return true;
      if (batch.length < pageSize) return false;
    }
    return false;
  }

  @override
  Future<List<SocialUserEntity>> getUserFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getUserFollowers(
      userId: userId,
      page: page,
      limit: limit,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<SocialUserEntity>> getUserFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getUserFollowing(
      userId: userId,
      page: page,
      limit: limit,
    );
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<SocialUserEntity>> getMyFollowers({
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getMyFollowers(page: page, limit: limit);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<SocialUserEntity>> getMyFollowing({
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getMyFollowing(page: page, limit: limit);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<SocialUserEntity>> getBlockedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getBlockedUsers(page: page, limit: limit);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<SocialUserEntity>> getTrueFriends({
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getTrueFriends(page: page, limit: limit);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<SocialUserEntity>> getSuggestedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getSuggestedUsers(page: page, limit: limit);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<SocialUserEntity>> getSuggestedArtists({
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getSuggestedArtists(page: page, limit: limit);
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
