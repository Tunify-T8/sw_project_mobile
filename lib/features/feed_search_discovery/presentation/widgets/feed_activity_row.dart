import 'package:flutter/material.dart';

class FeedActivityRow extends StatelessWidget {
  final String activityText;
  final String? avatarUrl;
  final String timeAgo;
  final String createdAt;

  const FeedActivityRow({
    super.key,
    required this.activityText,
    required this.avatarUrl,
    required this.timeAgo,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10.0,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        ),
        const SizedBox(width: 10.0),
        Text(
          activityText,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '· $createdAt ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
        Text(
          '· $timeAgo ago',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
