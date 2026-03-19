import '../../domain/entities/network_list_type.dart';
import 'network_lists_state.dart';

class NetworkListViewMapper {
  static Future<void> loadInitialData({
    required NetworkListType listType,
    required String userId,
    required dynamic notifier,
  }) async {
    switch (listType) {
      case NetworkListType.following:
        await notifier.loadFollowingList(userId: userId);
        break;
      case NetworkListType.followers:
        await notifier.loadFollowersList(userId: userId);
        break;
      case NetworkListType.suggested:
        await notifier.loadSuggestedUsers();
        break;
      case NetworkListType.blocked:
        await notifier.loadBlockedUsers();
        break;
      case NetworkListType.mutual:
        await notifier.loadMutualFriends(userId: userId);
        break;
    }
  }

  static List<dynamic> getUsers(
    NetworkListType listType,
    NetworkListsState state,
  ) {
    switch (listType) {
      case NetworkListType.following:
        return state.following;
      case NetworkListType.followers:
        return state.followers;
      case NetworkListType.suggested:
        return state.suggestedUsers;
      case NetworkListType.blocked:
        return state.blockedUsers;
      case NetworkListType.mutual:
        return state.mutualFriends;
    }
  }

  static String getTitle(NetworkListType listType) {
    switch (listType) {
      case NetworkListType.following:
        return 'Following';
      case NetworkListType.followers:
        return 'Followers';
      case NetworkListType.suggested:
        return 'Suggested Users';
      case NetworkListType.blocked:
        return 'Blocked Users';
      case NetworkListType.mutual:
        return 'Your true friends';
    }
  }

  static bool shouldShowTrueFriends({
    required NetworkListType listType,
    required String viewedUserId,
    required String currentUserId,
  }) {
    if (listType != NetworkListType.following) {
      return false;
    }

    final bool isMyProfile;
    isMyProfile = (viewedUserId == currentUserId);

    return isMyProfile;
  }
}
