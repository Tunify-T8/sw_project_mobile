import 'package:flutter/material.dart';
import '../../domain/entities/network_list_type.dart';
import '../../domain/entities/social_user_entity.dart';

class UserSocialTile extends StatelessWidget {
  final SocialUserEntity user;
  final NetworkListType listType;
  final VoidCallback? onFollowToggle;
  final VoidCallback? onToggleNotifications;
  final VoidCallback? onBlock;

  const UserSocialTile({
    super.key,
    required this.user,
    required this.listType,
    this.onFollowToggle,
    this.onToggleNotifications,
    this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = user.avatarUrl;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundImage:
                avatar != null && avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar == null || avatar.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 20.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 5.0),
                    Text(
                      '${user.followersCount ?? 0}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onFollowToggle,
            style: TextButton.styleFrom(
              backgroundColor:
                  user.isFollowing ? const Color(0xFF303030) : Colors.white,
              foregroundColor:
                  user.isFollowing ? Colors.white : Colors.black,
            ),
            child: Text(
              user.isFollowing ? 'Following' : 'Follow',
              style: const TextStyle(fontSize: 15.0),
            ),
          ),
          if (listType == NetworkListType.following)
            IconButton(
              onPressed: onToggleNotifications,
              icon: Icon(
                user.isNotificationEnabled
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