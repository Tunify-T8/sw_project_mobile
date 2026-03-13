import 'package:flutter/material.dart';

class UserSocialTile extends StatelessWidget {
  final String displayName;
  final int followersCount;
  final String avatarUrl;
  final bool isFollowing;
  final bool isNotificationEnabled;

  const UserSocialTile({
    required this.displayName,
    required this.followersCount,
    required this.avatarUrl,
    required this.isFollowing,
    required this.isNotificationEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          CircleAvatar(radius: 30.0, backgroundImage: NetworkImage(avatarUrl)),
          //Icon(Icons.ac_unit_sharp, color: Colors.white),
          SizedBox(width: 20.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.white),
                    SizedBox(width: 5.0),
                    Text(
                      followersCount.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: isFollowing ? Color(0xFF303030) : Colors.white,
              foregroundColor: isFollowing ? Colors.white : Colors.black,
            ),
            child: Text(
              isFollowing ? "Following" : "Follow",
              style: TextStyle(fontSize: 15.0),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Icon(
              isNotificationEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: Colors.white,
              size: 25.0,
            ),
          ),
        ],
      ),
    );
  }
}
