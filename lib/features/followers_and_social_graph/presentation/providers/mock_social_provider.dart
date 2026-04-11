// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'network_lists_state.dart';
// import 'social_graph_repository_provider.dart';

// class MockSocialNotifier extends Notifier<NetworkListsState> {
//   @override
//   NetworkListsState build() {
//     return const NetworkListsState();
//   }

//   Future<void> loadFollowingList({
//     required String userId,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       final repository = ref.read(socialGraphRepositoryProvider);
//       final following = await repository.getUserFollowing(
//         userId: userId,
//         page: page,
//         limit: limit,
//       );

//       state = state.copyWith(
//         isLoading: false,
//         following: following,
//         hasLoadedOnce: true,
//         error: null,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//         hasLoadedOnce: true,
//       );
//     }
//   }

//   Future<void> loadFollowersList({
//     required String userId,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       final repository = ref.read(socialGraphRepositoryProvider);
//       final followers = await repository.getUserFollowers(
//         userId: userId,
//         page: page,
//         limit: limit,
//       );

//       state = state.copyWith(
//         isLoading: false,
//         followers: followers,
//         hasLoadedOnce: true,
//         error: null,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//         hasLoadedOnce: true,
//       );
//     }
//   }

//   Future<void> loadSuggestedUsers({
//     int page = 1,
//     int limit = 20,
//     String? genre,
//   }) async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       final repository = ref.read(socialGraphRepositoryProvider);
//       final suggestedUsers = await repository.getSuggestedUsers(
//         page: page,
//         limit: limit,
//         genre: genre,
//       );

//       state = state.copyWith(
//         isLoading: false,
//         suggestedUsers: suggestedUsers,
//         hasLoadedOnce: true,
//         error: null,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//         hasLoadedOnce: true,
//       );
//     }
//   }

//   Future<void> loadBlockedUsers({int page = 1, int limit = 20}) async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       final repository = ref.read(socialGraphRepositoryProvider);
//       final blockedUsers = await repository.getBlockedUsers(
//         page: page,
//         limit: limit,
//       );

//       state = state.copyWith(
//         isLoading: false,
//         blockedUsers: blockedUsers,
//         hasLoadedOnce: true,
//         error: null,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//         hasLoadedOnce: true,
//       );
//     }
//   }

//   Future<void> loadMutualFriends({
//     required String userId,
//     int page = 1,
//     int limit = 20,
//   }) async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       final repository = ref.read(socialGraphRepositoryProvider);
//       final mutualFriends = await repository.getTrueFriends(
//         userId: userId,
//         page: page,
//         limit: limit,
//       );

//       state = state.copyWith(
//         isLoading: false,
//         mutualFriends: mutualFriends,
//         hasLoadedOnce: true,
//         error: null,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//         hasLoadedOnce: true,
//       );
//     }
//   }

//   Future<void> toggleFollow(String userId) async {
//     final user = [
//       ...state.following,
//       ...state.followers,
//       ...state.suggestedUsers,
//       ...state.mutualFriends,
//     ].firstWhere((u) => u.id == userId);

//     if (user.isFollowing) {
//       await unfollowUser(userId);
//     } else {
//       await followUser(userId);
//     }
//   }

//   Future<void> followUser(String userId) async {
//     try {
//       final repository = ref.read(socialGraphRepositoryProvider);
//       await repository.followUser(userId);

//       state = state.copyWith(
//         following: [
//           ...state.following,
//           ...state.followers
//               .where((user) => user.id == userId && !user.isFollowing)
//               .map((user) => user.copyWith(isFollowing: true)),
//         ],
//         followers: state.followers.map((user) {
//           if (user.id == userId) {
//             return user.copyWith(
//               isFollowing: true,
//               followersCount: (user.followersCount ?? 0) + 1,
//             );
//           }
//           return user;
//         }).toList(),
//         suggestedUsers: state.suggestedUsers.map((user) {
//           if (user.id == userId) {
//             return user.copyWith(
//               isFollowing: true,
//               followersCount: (user.followersCount ?? 0) + 1,
//             );
//           }
//           return user;
//         }).toList(),
//         mutualFriends: state.mutualFriends.map((user) {
//           if (user.id == userId) {
//             return user.copyWith(isFollowing: true);
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
//       final repository = ref.read(socialGraphRepositoryProvider);
//       await repository.unfollowUser(userId);

//       state = state.copyWith(
//         following: state.following.where((user) => user.id != userId).toList(),
//         followers: state.followers.map((user) {
//           if (user.id == userId) {
//             return user.copyWith(
//               isFollowing: false,
//               followersCount: ((user.followersCount ?? 1) - 1).clamp(
//                 0,
//                 1 << 30,
//               ),
//             );
//           }
//           return user;
//         }).toList(),
//         suggestedUsers: state.suggestedUsers.map((user) {
//           if (user.id == userId) {
//             return user.copyWith(
//               isFollowing: false,
//               followersCount: ((user.followersCount ?? 1) - 1).clamp(
//                 0,
//                 1 << 30,
//               ),
//             );
//           }
//           return user;
//         }).toList(),
//         mutualFriends: state.mutualFriends.map((user) {
//           if (user.id == userId) {
//             return user.copyWith(isFollowing: false);
//           }
//           return user;
//         }).toList(),
//       );
//     } catch (e) {
//       state = state.copyWith(error: e.toString());
//     }
//   }

//   Future<void> toggleBlock(String userId) async {
//     final user = [
//       ...state.blockedUsers,
//       ...state.followers,
//       ...state.following,
//       ...state.suggestedUsers,
//       ...state.mutualFriends,
//     ].firstWhere((u) => u.id == userId);

//     if (user.isBlocked) {
//       await unblockUser(userId);
//     } else {
//       await blockUser(userId);
//     }
//   }

//   Future<void> blockUser(String userId) async {
//     try {
//       final repository = ref.read(socialGraphRepositoryProvider);
//       await repository.blockUser(userId);

//       final blockedUser = [
//         ...state.followers,
//         ...state.following,
//         ...state.suggestedUsers,
//         ...state.mutualFriends,
//       ].where((user) => user.id == userId).toList();

//       state = state.copyWith(
//         followers: state.followers.where((user) => user.id != userId).toList(),
//         following: state.following.where((user) => user.id != userId).toList(),
//         suggestedUsers: state.suggestedUsers
//             .where((user) => user.id != userId)
//             .toList(),
//         mutualFriends: state.mutualFriends
//             .where((user) => user.id != userId)
//             .toList(),
//         blockedUsers: [
//           ...state.blockedUsers,
//           ...blockedUser.map(
//             (user) => user.copyWith(isFollowing: false, isBlocked: true),
//           ),
//         ],
//       );
//     } catch (e) {
//       state = state.copyWith(error: e.toString());
//     }
//   }

//   Future<void> unblockUser(String userId) async {
//     try {
//       final repository = ref.read(socialGraphRepositoryProvider);
//       await repository.unblockUser(userId);

//       state = state.copyWith(
//         blockedUsers: state.blockedUsers
//             .where((user) => user.id != userId)
//             .toList(),
//         followers: state.followers.map((user) {
//           if (user.id == userId) {
//             return user.copyWith(isBlocked: false);
//           }
//           return user;
//         }).toList(),
//         following: state.following.map((user) {
//           if (user.id == userId) {
//             return user.copyWith(isBlocked: false);
//           }
//           return user;
//         }).toList(),
//       );
//     } catch (e) {
//       state = state.copyWith(error: e.toString());
//     }
//   }

//   void clearError() {
//     state = state.copyWith(error: null);
//   }

//   void toggleNotifications(String userId) {
//     state = state.copyWith(
//       following: state.following.map((user) {
//         if (user.id == userId) {
//           return user.copyWith(
//             isNotificationEnabled: !user.isNotificationEnabled,
//           );
//         }
//         return user;
//       }).toList(),
//     );
//   }
// }

// final mockSocialProvider =
//     NotifierProvider<MockSocialNotifier, NetworkListsState>(
//       MockSocialNotifier.new,
//     );
