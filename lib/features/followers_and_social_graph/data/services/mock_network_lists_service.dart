import 'dart:async';

class MockNetworkListsService {
  Future<List<Map<String, dynamic>>> fetchFollowingList({
    required String userID,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      {
        "id": "u1",
        "displayName": "Alice",
        "avatarUrl": "https://i.pravatar.cc/150?img=1",
        "followersCount": 120,
        "isFollowing": true,
        "isNotificationEnabled": true,
      },
      {
        "id": "u2",
        "displayName": "Mark",
        "avatarUrl": "https://i.pravatar.cc/150?img=2",
        "followersCount": 340,
        "isFollowing": true,
        "isNotificationEnabled": false,
      },
      {
        "id": "u3",
        "displayName": "IDK",
        "avatarUrl": "https://i.pravatar.cc/150?img=3",
        "followersCount": 30,
        "isFollowing": true,
      },
    ];
  }

  Future<List<Map<String, dynamic>>> fetchFollowersList({
    required String userID,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      {
        "id": "u1",
        "displayName": "Alice",
        "avatarUrl": "https://i.pravatar.cc/150?img=1",
        "followersCount": 120,
        "isFollowing": true,
      },
      {
        "id": "u2",
        "displayName": "Mark",
        "avatarUrl": "https://i.pravatar.cc/150?img=3",
        "followersCount": 340,
        "isFollowing": true,
      },
      {
        "id": "u3",
        "displayName": "IDK",
        "avatarUrl": "https://i.pravatar.cc/150?img=2",
        "followersCount": 30,
        "isFollowing": false,
      },
    ];
  }
}
