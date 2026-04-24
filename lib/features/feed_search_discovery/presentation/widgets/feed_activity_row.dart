import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../../domain/entities/feed_item_source.dart';
import '../../domain/entities/feed_tab_type.dart';

class FeedActivityRow extends StatelessWidget {
  final String? avatarUrl;
  final String timeAgo;
  final String? createdAt;
  final FeedType feedType;
  final FeedItemSource source;
  final String actorName;
  final String trackName;

  const FeedActivityRow({
    super.key,
    required this.avatarUrl,
    required this.timeAgo,
    this.createdAt,
    required this.feedType,
    required this.source,
    required this.actorName,
    required this.trackName,
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
    final activityText = _getActivityText();
    return Row(
      children: [
        CircleAvatar(
          radius: 10.0,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        ),
        const SizedBox(width: 10.0),

        Expanded(
          child: SizedBox(
            height: 22,
            child: activityText.length > 25
                ? Marquee(
                    text: activityText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    blankSpace: 50.0,
                    velocity: 20.0,
                    pauseAfterRound: Duration(seconds: 2),
                    startPadding: 10.0,
                    accelerationDuration: Duration(seconds: 1),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: Duration(milliseconds: 500),
                    decelerationCurve: Curves.easeOut,
                  )
                : Text(
                    activityText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
        if (feedType != FeedType.following && createdAt != null)
          Text(
            '· $createdAt ',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        Text(
          '· $timeAgo',
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
