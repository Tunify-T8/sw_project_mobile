import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../../domain/entities/feed_item_source.dart';
import '../../domain/entities/feed_view_mode.dart';
import '../../domain/entities/feed_tab_type.dart';

class FeedActivityRow extends StatelessWidget {
  final String? avatarUrl;
  final String timeAgo;
  final String? createdAt;
  final FeedViewMode feedViewMode;
  final FeedItemSource? source;
  final String? actorName;
  final String? discoverReason;
  final String trackName;
  final FeedType feedType;

  const FeedActivityRow({
    super.key,
    required this.avatarUrl,
    required this.timeAgo,
    this.createdAt,
    required this.feedViewMode,
    this.source,
    this.actorName,
    this.discoverReason,
    required this.trackName,
    required this.feedType,
  });

  String _getActivityText() {
    String activityText = ' ';
    if (discoverReason != null) {
      activityText = discoverReason!;
    } else if (source != null) {
      switch (source!) {
        case FeedItemSource.post:
          activityText = ' $actorName posted a track';
        case FeedItemSource.repost:
          activityText = '$actorName reposted a track';
      }

      if (feedViewMode == FeedViewMode.discover && createdAt != null) {
        activityText += " • $createdAt";
      }

      activityText += " • $timeAgo";
    }

    return activityText;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      key: ValueKey('feed_activity_row_${feedViewMode.name}_$trackName'),
      children: [
        (feedType == FeedType.following)
            ? CircleAvatar(
                radius: 10.0,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                backgroundColor: Colors.grey,
              )
            : Icon(Icons.star, color: Colors.white, size: 20,),

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
