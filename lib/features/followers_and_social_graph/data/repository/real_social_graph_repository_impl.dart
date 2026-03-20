import '../../domain/entities/social_relation_entity.dart';
import '../../domain/entities/social_user_entity.dart';
import '../../domain/repositories/social_graph_repository.dart';
import '../api/social_api.dart';
import '../mappers/social_relation_mapper.dart';
import '../mappers/social_user_mapper.dart';

class RealSocialGraphRepositoryImpl implements SocialGraphRepository {
  final SocialApi api;

  RealSocialGraphRepositoryImpl(this.api);

  @override
  Future<List<SocialUserEntity>> getFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getFollowers(
      userId: userId,
      page: page,
      limit: limit,
    );

    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<SocialUserEntity>> getFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getFollowing(
      userId: userId,
      page: page,
      limit: limit,
    );

    return dtos.map((dto) => dto.toEntity()).toList();
  }

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
  Future<List<SocialUserEntity>> getBlockedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getBlockedUsers(page: page, limit: limit);

    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<SocialUserEntity>> getSuggestedUsers({
    int page = 1,
    int limit = 20,
    String? genre,
  }) async {
    final dtos = await api.getSuggestedUsers(
      page: page,
      limit: limit,
      genre: genre,
    );

    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<SocialRelationEntity> getFollowStatus(String userId) async {
    final dto = await api.getFollowStatus(userId);
    return dto.toEntity(userId);
  }

  @override
  Future<List<SocialUserEntity>> getMutualFriends({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final dtos = await api.getMutualFriends(
      userId: userId,
      page: page,
      limit: limit,
    );

    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
