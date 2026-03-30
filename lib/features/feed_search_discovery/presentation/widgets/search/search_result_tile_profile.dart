// lib/features/feed_search_discovery/presentation/widgets/search/search_result_tile_profile.dart

import 'package:flutter/material.dart';
import '../../../domain/entities/profile_result_entity.dart';

class SearchResultTileProfile extends StatelessWidget {
  const SearchResultTileProfile({super.key, required this.profile});
  final ProfileResultEntity profile;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              style: const TextStyle(color: Colors.white, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (profile.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ],
      ),
      subtitle: Text(
        _formatFollowers(profile.followersCount),
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white38),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(64, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 13),
        ),
        child: Text(profile.isFollowing ? 'Following' : 'Follow'),
      ),
    );
  }

  String _formatFollowers(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M Followers';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}K Followers';
    }
    return '$count Followers';
  }
}
