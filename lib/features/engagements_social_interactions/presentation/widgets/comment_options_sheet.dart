import 'package:flutter/material.dart';

import '../utils/engagement_formatters.dart';

class CommentOptionsSheet extends StatelessWidget {
  const CommentOptionsSheet({
    super.key,
    required this.username,
    this.timestamp,
    this.onPlayFromTimestamp,
  });

  final String username;
  final int? timestamp;
  final VoidCallback? onPlayFromTimestamp;

  @override
  Widget build(BuildContext context) {
    final header = timestamp != null
        ? '$username at ${EngagementFormatters.timestamp(timestamp!)}'
        : username;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                header,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          if (timestamp != null)
            ListTile(
              leading: const Icon(Icons.play_circle_outline, color: Colors.white70),
              title: Text(
                'Play from ${EngagementFormatters.timestamp(timestamp!)}',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                onPlayFromTimestamp?.call();
              },
            ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white70),
            title: const Text('Go to profile', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined, color: Colors.white70),
            title: const Text('Copy', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined, color: Colors.white70),
            title: const Text('Report', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.outlined_flag, color: Colors.white70),
            title: const Text('Report as spam', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.white70),
            title: const Text('Block', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String username,
    int? timestamp,
    VoidCallback? onPlayFromTimestamp,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CommentOptionsSheet(
        username: username,
        timestamp: timestamp,
        onPlayFromTimestamp: onPlayFromTimestamp,
      ),
    );
  }
}
