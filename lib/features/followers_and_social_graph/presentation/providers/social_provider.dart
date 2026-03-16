// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../domain/entities/social_user_entity.dart';
// import '../../domain/entities/social_relation_entity.dart';
// import 'social_repository_provider.dart';
// import 'social_state.dart';

// class SocialNotifier extends Notifier<SocialState> {
//   @override
//   SocialState build() {
//     return const SocialState();
//   }

//   Future<void> loadFollowers({
//     required String userId,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     state = state.copyWith(
//       isLoadingFollowers: true,
//       error: null,
//     );

//     try {
//       final repository = ref.read(socialRepositoryProvider);
//       final followers = await repository.getFollowers(
//         userId: userId,
//         page: page,
//         limit: limit,
//       );

//       state = state.copyWith(
//         isLoadingFollowers: false,
//         followers: followers,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoadingFollowers: false,
//         error: e.toString(),
//       );
//     }
//   }

//   Future<void> loadFollowing({
//     required String userId,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     state = state.copyWith(
//       isLoadingFollowing: true,
//       error: null,
//     );

//     try {
//       final repository = ref.read(socialRepositoryProvider);
//       final following = await repository.getFollowing(
//         userId: userId,
//         page: page,
//         limit: limit,
//       );

//       state = state.copyWith(
//         isLoadingFollowing: false,
//         following: following,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoadingFollowing: false,
//         error: e.toString(),
//       );
//     }
//   }

//   Future<void> loadBlockedUsers({
//     int page = 1,
//     int limit = 20,
//   }) async {
//     state = state.copyWith(
//       isLoadingBlockedUsers: true,
//       error: null,
//     );

//     try {
//       final repository = ref.read(socialRepositoryProvider);
//       final blockedUsers = await repository.getBlockedUsers(
//         page: page,
//         limit: limit,
//       );

//       state = state.copyWith(
//         isLoadingBlockedUsers: false,
//         blockedUsers: blockedUsers,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoadingBlockedUsers: false,
//         error: e.toString(),
//       );
//     }
//   }

//   Future<void> loadSuggestedUsers({
//     int page = 1,
//     int limit = 20,
//     String? genre,
//   }) async {
//     state = state.copyWith(
//       isLoadingSuggestedUsers: true,
//       error: null,
//     );

//     try {
//       final repository = ref.read(socialRepositoryProvider);
//       final suggestedUsers = await repository.getSuggestedUsers(
//         page: page,
//         limit: limit,
//         genre: genre,
//       );

//       state = state.copyWith(
//         isLoadingSuggestedUsers: false,
//         suggestedUsers: suggestedUsers,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoadingSuggestedUsers: false,
//         error: e.toString(),
//       );
//     }
//   }

//   Future<void> loadMutualFriends({
//     required String userId,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     state = state.copyWith(
//       isLoadingMutualFriends: true,
//       error: null,
//     );

//     try {
//       final repository = ref.read(socialRepositoryProvider);
//       final mutualFriends = await repository.getMutualFriends(
//         userId: userId,
//         page: page,
//         limit: limit,
//       );

//       state = state.copyWith(
//         isLoadingMutualFriends: false,
//         mutualFriends: mutualFriends,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoadingMutualFriends: false,
//         error: e.toString(),
//       );
//     }
//   }

//   Future<void> loadFollowStatus(String userId) async {
//     state = state.copyWith(
//       isLoadingFollowStatus: true,
//       error: null,
//     );

//     try {
//       final repository = ref.read(socialRepositoryProvider);
//       final followStatus = await repository.getFollowStatus(userId);

//       state = state.copyWith(
//         isLoadingFollowStatus: false,
//         followStatus: followStatus,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoadingFollowStatus: false,
//         error: e.toString(),
//       );
//     }
//   }

//   Future<void> followUser(String userId) async {
//     try {
//       final repository = ref.read(socialRepositoryProvider);
//       await repository.followUser(userId);

//       final currentStatus = state.followStatus;
//       if (currentStatus != null) {
//         state = state.copyWith(
//           followStatus: currentStatus.copyWith(
//             targetUserId: userId,
//             isFollowing: true,
//             isMutual: currentStatus.isFollowedBy,
//           ),
//         );
//       }

//       state = state.copyWith(
//         suggestedUsers: state.suggestedUsers.map((user) {
//           if (user.id == userId) {
//             return user.copyWith(
//               followersCount: (user.followersCount ?? 0) + 1,
//             );
//           }
//           return user;
//         }).toList(),
//       );
//     } catch (e) {
//       state = state.copyWith(error: e.toString());
//     }
//   }

//   Future<void> unfollowUser(String userId) async {
//     try {
//       final repository = ref.read(socialRepositoryProvider);
//       await repository.unfollowUser(userId);

//       final currentStatus = state.followStatus;
//       if (currentStatus != null) {
//         state = state.copyWith(
//           followStatus: currentStatus.copyWith(
//             targetUserId: userId,
//             isFollowing: false,
//             isMutual: false,
//           ),
//         );
//       }

//       state = state.copyWith(
//         following: state.following.where((user) => user.id != userId).toList(),
//         suggestedUsers: state.suggestedUsers.map((user) {
//           if (user.id == userId) {
//             return user.copyWith(
//               followersCount: ((user.followersCount ?? 1) - 1).clamp(0, 1 << 30),
//             );
//           }
//           return user;
//         }).toList(),
//       );
//     } catch (e) {
//       state = state.copyWith(error: e.toString());
//     }
//   }

//   Future<void> blockUser(String userId) async {
//     try {
//       final repository = ref.read(socialRepositoryProvider);
//       await repository.blockUser(userId);

//       state = state.copyWith(
//         followers: state.followers.where((user) => user.id != userId).toList(),
//         following: state.following.where((user) => user.id != userId).toList(),
//         suggestedUsers:
//             state.suggestedUsers.where((user) => user.id != userId).toList(),
//         mutualFriends:
//             state.mutualFriends.where((user) => user.id != userId).toList(),
//       );
//     } catch (e) {
//       state = state.copyWith(error: e.toString());
//     }
//   }

//   Future<void> unblockUser(String userId) async {
//     try {
//       final repository = ref.read(socialRepositoryProvider);
//       await repository.unblockUser(userId);

//       state = state.copyWith(
//         blockedUsers:
//             state.blockedUsers.where((user) => user.id != userId).toList(),
//       );
//     } catch (e) {
//       state = state.copyWith(error: e.toString());
//     }
//   }

//   void clearError() {
//     state = state.copyWith(error: null);
//   }
// }

// final socialProvider =
//     NotifierProvider<SocialNotifier, SocialState>(SocialNotifier.new);