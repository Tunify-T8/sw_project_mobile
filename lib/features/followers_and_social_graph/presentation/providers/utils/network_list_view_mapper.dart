import 'package:software_project/features/followers_and_social_graph/domain/entities/social_user_entity.dart';

import '../../../domain/entities/network_list_type.dart';
import '../network_lists_state.dart';

class NetworkListViewMapper {
  static Future<void> loadInitialData({
    required NetworkListType listType,
    String? userId,
    required bool isMyProfile,
    required dynamic notifier,
  }) async {
    switch (listType) {
      case NetworkListType.following:
        if (isMyProfile) {
          await notifier.loadMyFollowing();
        } else if (userId != null) {
          await notifier.loadFollowingList(userId: userId);
        }
        break;

      case NetworkListType.followers:
        if (isMyProfile) {
          await notifier.loadMyFollowers();
        } else if (userId != null) {
          await notifier.loadFollowersList(userId: userId);
        }
        break;

      case NetworkListType.suggestedUsers:
        await notifier.loadSuggestedUsers();
        break;

      case NetworkListType.suggestedArtists:
        await notifier.loadSuggestedArtists();
        break;

      case NetworkListType.blocked:
        await notifier.loadBlockedUsers();
        break;

      case NetworkListType.trueFriends:
        await notifier.loadTrueFriends();
        break;
    }
  }

  static List<SocialUserEntity> getUsers(
    NetworkListType listType,
    NetworkListsState state,
  ) {
    return state.userLists[listType] ?? [];
  }

  static String getTitle(NetworkListType listType) {
    switch (listType) {
      case NetworkListType.following:
        return 'Following';
      case NetworkListType.followers:
        return 'Followers';
      case NetworkListType.suggestedUsers:
        return 'Suggested Users';
      case NetworkListType.suggestedArtists:
        return 'Suggested Artists';
      case NetworkListType.blocked:
        return 'Blocked Users';
      case NetworkListType.trueFriends:
        return 'Your true friends';
    }
  }

  static bool shouldShowTrueFriends({
    required NetworkListType listType,
    required bool isMyProfile,
  }) {
    if (listType != NetworkListType.following) {
      return false;
    }
    return isMyProfile;
  }
}
