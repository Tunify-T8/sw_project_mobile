import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../dto/social_relation_dto.dart';
import '../dto/social_user_dto.dart';

class SocialApi {
  final Dio dio;

  SocialApi(this.dio);

  Future<List<SocialUserDTO>> getFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getFollowers(userId),
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final followers = data['followers'] as List<dynamic>;

    return followers
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SocialUserDTO>> getFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getFollowing(userId),
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final following = data['following'] as List<dynamic>;

    return following
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> followUser(String userId) async {
    await dio.post(ApiEndpoints.followUser(userId));
  }

  Future<void> unfollowUser(String userId) async {
    await dio.delete(ApiEndpoints.unfollowUser(userId));
  }

  Future<void> blockUser(String userId) async {
    await dio.post(ApiEndpoints.blockUser(userId));
  }

  Future<void> unblockUser(String userId) async {
    await dio.delete(ApiEndpoints.unblockUser(userId));
  }

  Future<List<SocialUserDTO>> getBlockedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getBlockedUsers(),
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final blockedUsers = data['blockedUsers'] as List<dynamic>;

    return blockedUsers
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SocialUserDTO>> getSuggestedUsers({
    int page = 1,
    int limit = 20,
    String? genre,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getSuggestedUsers(),
      queryParameters: {
        'page': page,
        'limit': limit,
        if (genre != null) 'genre': genre,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final users = data['users'] as List<dynamic>;

    return users
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SocialRelationDTO> getFollowStatus(String userId) async {
    final response = await dio.get(ApiEndpoints.getFollowStatus(userId));

    return SocialRelationDTO.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<SocialUserDTO>> getMutualFriends({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getMutualFriends(userId),
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final mutualFriends = data['mutualFriends'] as List<dynamic>;

    return mutualFriends
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
