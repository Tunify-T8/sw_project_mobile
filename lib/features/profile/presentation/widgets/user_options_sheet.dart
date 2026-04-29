import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserOptionsSheet extends ConsumerWidget {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final int followersCount;
  final int tracksCount;
  final bool isFollowing;
  final bool isBlocked;
  final VoidCallback onFollowChanged;
  final VoidCallback onBlockChanged;

  const UserOptionsSheet({
    super.key,
    required this.userId,
    required this.userName,
    required this.followersCount,
    required this.tracksCount,
    required this.isFollowing,
    required this.isBlocked,
    required this.onFollowChanged,
    required this.onBlockChanged,
    this.avatarUrl,
  });

  static void show({
    required BuildContext context,
    required String userId,
    required String userName,
    required int followersCount,
    required int tracksCount,
    required bool isFollowing,
    required bool isBlocked,
    required VoidCallback onFollowChanged,
    required VoidCallback onBlockChanged,
    String? avatarUrl,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => UserOptionsSheet(
        userId: userId,
        userName: userName,
        avatarUrl: avatarUrl,
        followersCount: followersCount,
        tracksCount: tracksCount,
        isFollowing: isFollowing,
        isBlocked: isBlocked,
        onFollowChanged: onFollowChanged,
        onBlockChanged: onBlockChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? NetworkImage(avatarUrl!)
                    : null,
                backgroundColor: Colors.grey.shade800,
                child: avatarUrl == null || avatarUrl!.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$followersCount Followers · $tracksCount Tracks',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white12),

        // Follow / Unfollow
        if (!isBlocked)
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white),
            title: Text(
              isFollowing ? 'Unfollow' : 'Follow',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              onFollowChanged();
            },
          ),

        // Start station
        ListTile(
          leading: const Icon(Icons.radio, color: Colors.white),
          title: const Text(
            'Start station',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () => Navigator.pop(context),
        ),

        // View info
        ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.white),
          title: const Text('View info', style: TextStyle(color: Colors.white)),
          onTap: () => Navigator.pop(context),
        ),

        const Divider(color: Colors.white12),

        // Request Missing Music
        ListTile(
          leading: const Icon(Icons.edit_outlined, color: Colors.white),
          title: const Text(
            'Request Missing Music',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () => Navigator.pop(context),
        ),

        // Report
        ListTile(
          leading: const Icon(Icons.flag_outlined, color: Colors.white),
          title: const Text('Report', style: TextStyle(color: Colors.white)),
          onTap: () => Navigator.pop(context),
        ),

        // Block user
        ListTile(
          leading: const Icon(Icons.block, color: Colors.white),
          title: Text(
            isBlocked ? 'Unblock' : 'Block user',
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.pop(context);
            onBlockChanged();
          },
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}
