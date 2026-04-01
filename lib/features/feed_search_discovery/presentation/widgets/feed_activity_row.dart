import 'package:flutter/material.dart';
import '../../domain/entities/feed_item_source.dart';

class FeedActivityRow extends StatelessWidget {
  final String? avatarUrl;
  final String timeAgo;
  final String createdAt;
  final FeedItemSource source;
  final String actorName;
  final String trackName;

  const FeedActivityRow({
    super.key,
    required this.avatarUrl,
    required this.timeAgo,
    required this.createdAt,
    required this.source,
    required this.actorName,
    required this.trackName
  });

  String _getActivityText() {
    switch (source) {
      case FeedItemSource.post:
        return ' $actorName posted a track';
      case FeedItemSource.repost:
        return '$actorName reposted a track';
      case FeedItemSource.newRelease:
        return 'New release by $actorName';
      case FeedItemSource.becauseYouLiked:
        return 'Because you liked $trackName by $actorName';
      case FeedItemSource.becauseYouFollow:
       return 'Because you follow $actorName';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10.0,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            _getActivityText(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '· $createdAt ',
          style: const TextStyle(color: Colors.white70, fontSize: 15),
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
