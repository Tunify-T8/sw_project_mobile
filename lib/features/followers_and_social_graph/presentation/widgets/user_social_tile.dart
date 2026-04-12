import 'package:flutter/material.dart';
import '../../domain/entities/network_list_type.dart';
import '../../domain/entities/social_user_entity.dart';
import 'relationship_button.dart';

class UserSocialTile extends StatelessWidget {
  final SocialUserEntity user;
  final NetworkListType listType;
  final VoidCallback? onTap;
  final VoidCallback? onToggleNotifications;

  const UserSocialTile({
    super.key,
    required this.user,
    required this.listType,
    this.onTap,
    this.onToggleNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = user.avatarUrl;
    final bool blockedList = (listType == NetworkListType.blocked)
        ? true
        : false;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            CircleAvatar(
              //check if back end will have default value
              radius: 30.0,
              backgroundImage: avatar != null && avatar.isNotEmpty
                  ? NetworkImage(avatar)
                  : null,
              child: avatar == null || avatar.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 20.0),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      if (user.isCertified)
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20.0,
                          ),
                        ),
                    ],
                  ),
                  if (user.location != null && user.location!.isNotEmpty)
                    Text(
                      user.location!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
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

            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: RelationshipButton(
                userId: user.id,
                initialIsFollowing: user.isFollowing,
                initialIsBlocked: user.isBlocked,
                isBlockMode: blockedList,
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
      ),
    );
  }
}
