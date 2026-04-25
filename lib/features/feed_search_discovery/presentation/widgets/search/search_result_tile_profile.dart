import 'package:flutter/material.dart';
import '../../../../../features/followers_and_social_graph/presentation/widgets/relationship_button.dart';
import '../../../domain/entities/profile_result_entity.dart';

/// Search result tile for a user profile.
///
/// FIX: Added optional [onTap] callback for profile navigation.
/// FIX: Follow button now uses [RelationshipButton] — same widget used in
/// the home feed and suggested users — so follow/unfollow actually works.
class SearchResultTileProfile extends StatelessWidget {
  const SearchResultTileProfile({super.key, required this.profile, this.onTap});

  final ProfileResultEntity profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final secondLine = profile.location?.isNotEmpty == true
        ? profile.location!
        : profile.isVerified
        ? 'Verified'
        : null;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF2A2A2A),
        backgroundImage: profile.avatarUrl != null
            ? NetworkImage(profile.avatarUrl!)
            : null,
        child: profile.avatarUrl == null
            ? const Icon(Icons.person, color: Colors.white54, size: 22)
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              profile.username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (profile.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 14),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (secondLine != null)
            Text(
              secondLine,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.white38, size: 13),
              const SizedBox(width: 3),
              Text(
                '${_fmt(profile.followersCount)} Followers',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      trailing: RelationshipButton(
        userId: profile.id,
        initialIsFollowing: profile.isFollowing,
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }
}
