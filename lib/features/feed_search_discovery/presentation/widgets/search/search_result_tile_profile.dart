import 'package:flutter/material.dart';
import '../../../domain/entities/profile_result_entity.dart';

class SearchResultTileProfile extends StatelessWidget {
  const SearchResultTileProfile({super.key, required this.profile});
  final ProfileResultEntity profile;

  @override
  Widget build(BuildContext context) {
    // Second line: country if available, otherwise show verified badge text
    final secondLine = profile.location?.isNotEmpty == true
        ? profile.location!
        : profile.isVerified
        ? 'Verified'
        : null;

    return ListTile(
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
      trailing: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white38),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          minimumSize: const Size(64, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: Text(profile.isFollowing ? 'Following' : 'Follow'),
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1)}M';
    }
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(0)}K';
    }
    return n.toString();
  }
}
