import 'package:flutter/material.dart';
import '../../domain/entities/social_user_entity.dart';

class SuggestedUserItem extends StatelessWidget {
  final SocialUserEntity user;
  final VoidCallback onFollowToggle;

  const SuggestedUserItem({
    super.key,
    required this.user,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isFollowing = user.isFollowing;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: SizedBox(
        width: 140,
        child: Column(
          children: [
            CircleAvatar(
              radius: 50, 
              backgroundImage: user.avatarUrl != null &&
                      user.avatarUrl!.isNotEmpty
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),

            const SizedBox(height: 12), 

            Text(
              user.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 38, 
              child: TextButton(
                onPressed: onFollowToggle,
                style: TextButton.styleFrom(
                  backgroundColor:
                      isFollowing ? const Color(0xFF303030) : Colors.white,
                  foregroundColor:
                      isFollowing ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}