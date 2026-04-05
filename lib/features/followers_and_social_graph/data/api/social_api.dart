import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../dto/social_relation_dto.dart';
import '../dto/social_user_dto.dart';

class SocialApi {
  final Dio dio;

  SocialApi(this.dio);

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

  Future<SocialRelationDTO> getFollowStatus(String userId) async {
    final response = await dio.get(ApiEndpoints.getFollowStatus(userId));

    return SocialRelationDTO.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<SocialUserDTO>> getUserFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getUserFollowers(userId),
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data as Map<String, dynamic>;
    final followers = data['followers'] as List<dynamic>;

    return followers
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SocialUserDTO>> getUserFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getUserFollowing(userId),
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data as Map<String, dynamic>;
    final following = data['following'] as List<dynamic>;

    return following
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SocialUserDTO>> getMyFollowers({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getMyFollowers,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data as Map<String, dynamic>;
    final followers = data['followers'] as List<dynamic>;

    return followers
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SocialUserDTO>> getMyFollowing({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getMyFollowing,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data as Map<String, dynamic>;
    final following = data['following'] as List<dynamic>;

    return following
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SocialUserDTO>> getBlockedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getBlockedUsers,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data as Map<String, dynamic>;
    final blockedUsers = data['data'] as List<dynamic>;

    return blockedUsers
        .map(
          (json) => SocialUserDTO.fromJson(
            (json as Map<String, dynamic>)['user'] as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<SocialUserDTO>> getTrueFriends({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getTrueFriends,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data as Map<String, dynamic>;
    final mutualFriends = data['data'] as List<dynamic>;

    return mutualFriends
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SocialUserDTO>> getSuggestedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getSuggestedUsers,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data as Map<String, dynamic>;
    final users = data['data'] as List<dynamic>;

    return users
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SocialUserDTO>> getSuggestedArtists({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getSuggestedArtists,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data as Map<String, dynamic>;
    final users = data['data'] as List<dynamic>;

    return users
        .map((json) => SocialUserDTO.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
