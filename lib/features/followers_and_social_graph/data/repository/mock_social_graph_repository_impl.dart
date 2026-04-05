// import '../../domain/entities/social_relation_entity.dart';
// import '../../domain/entities/social_user_entity.dart';
// import '../../domain/repositories/social_graph_repository.dart';
// import '../dto/social_relation_dto.dart';
// import '../dto/social_user_dto.dart';
// import '../mappers/social_relation_mapper.dart';
// import '../mappers/social_user_mapper.dart';
// import '../services/mock_social_graph_service.dart';

// class MockSocialGraphRepositoryImpl implements SocialGraphRepository {
//   final MockSocialGraphService service;

//   MockSocialGraphRepositoryImpl({required this.service});

//   @override
//   Future<List<SocialUserEntity>> getUserFollowers({
//     required String userId,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     final data = await service.getFollowers(
//       userId: userId,
//       page: page,
//       limit: limit,
//     );

//     return data.map((json) => SocialUserDTO.fromJson(json).toEntity()).toList();
//   }

//   @override
//   Future<List<SocialUserEntity>> getUserFollowing({
//     required String userId,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     final data = await service.getFollowing(
//       userId: userId,
//       page: page,
//       limit: limit,
//     );

//     return data.map((json) => SocialUserDTO.fromJson(json).toEntity()).toList();
//   }

//   @override
//   Future<void> followUser(String userId) async {
//     await service.followUser(userId: userId);
//   }

//   @override
//   Future<void> unfollowUser(String userId) async {
//     await service.unfollowUser(userId: userId);
//   }

//   @override
//   Future<void> blockUser(String userId) async {
//     await service.blockUser(userId: userId);
//   }

//   @override
//   Future<void> unblockUser(String userId) async {
//     await service.unblockUser(userId: userId);
//   }

//   @override
//   Future<List<SocialUserEntity>> getBlockedUsers({
//     int page = 1,
//     int limit = 20,
//   }) async {
//     final data = await service.getBlockedUsers(page: page, limit: limit);

//     return data.map((json) => SocialUserDTO.fromJson(json).toEntity()).toList();
//   }

//   @override
//   Future<List<SocialUserEntity>> getSuggestedUsers({
//     int page = 1,
//     int limit = 20,
//     String? genre,
//   }) async {
//     final data = await service.getSuggestedUsers(
//       page: page,
//       limit: limit,
//       genre: genre,
//     );

//     return data.map((json) => SocialUserDTO.fromJson(json).toEntity()).toList();
//   }

//   @override
//   Future<SocialRelationEntity> getFollowStatus(String userId) async {
//     final data = await service.getFollowStatus(userId: userId);

//     return SocialRelationDTO.fromJson(data).toEntity(userId);
//   }

//   @override
//   Future<List<SocialUserEntity>> getTrueFriends({
//     required String userId,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     final data = await service.getMutualFriends(
//       userId: userId,
//       page: page,
//       limit: limit,
//     );

//     return data.map((json) => SocialUserDTO.fromJson(json).toEntity()).toList();
//   }
// }
