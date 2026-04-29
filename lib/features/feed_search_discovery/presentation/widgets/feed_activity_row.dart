import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../../domain/entities/feed_item_source.dart';
import '../../domain/entities/feed_view_mode.dart';

class FeedActivityRow extends StatelessWidget {
  final String? avatarUrl;
  final String timeAgo;
  final String? createdAt;
  final FeedViewMode feedViewMode;
  final FeedItemSource source;
  final String actorName;
  final String trackName;

  const FeedActivityRow({
    super.key,
    required this.avatarUrl,
    required this.timeAgo,
    this.createdAt,
    required this.feedViewMode,
    required this.source,
    required this.actorName,
    required this.trackName,
  });

  String _getActivityText() {
    String activityText;
    switch (source) {
      case FeedItemSource.post:
        activityText = ' $actorName posted a track';
      case FeedItemSource.repost:
        activityText = '$actorName reposted a track';
      case FeedItemSource.newRelease:
        activityText = 'New release by $actorName';
      case FeedItemSource.becauseYouLiked:
        activityText = 'Because you liked $trackName by $actorName';
      case FeedItemSource.becauseYouFollow:
        activityText = 'Because you follow $actorName';
    }

    if (feedViewMode == FeedViewMode.discover && createdAt != null) {
      activityText += " • $createdAt";
    }

    activityText += " • $timeAgo";
    return activityText;
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
          child: SizedBox(
            height: 22,
            child:
                (_getActivityText().length > 35 &&
                    (feedViewMode == FeedViewMode.discover) &&
                    (MediaQuery.of(context).size.width < 600))
                ? Marquee(
                    text: _getActivityText(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    blankSpace: 80.0,
                    velocity: 20.0,
                    pauseAfterRound: Duration(seconds: 2),
                    startPadding: 10.0,
                    accelerationDuration: Duration(seconds: 2),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: Duration(milliseconds: 500),
                    decelerationCurve: Curves.easeOut,
                  )
                : Text(
                    _getActivityText(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
      ],
    );
  }
}
