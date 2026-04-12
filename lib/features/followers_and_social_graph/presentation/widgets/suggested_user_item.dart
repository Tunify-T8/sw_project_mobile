import 'package:flutter/material.dart';
import '../../domain/entities/social_user_entity.dart';
import 'relationship_button.dart';


class SuggestedUserItem extends StatelessWidget {
  final SocialUserEntity user;
  final VoidCallback? onTap;

  const SuggestedUserItem({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 140,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    user.avatarUrl != null && user.avatarUrl!.isNotEmpty
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

              RelationshipButton(
                userId: user.id,
                initialIsFollowing: user.isFollowing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
