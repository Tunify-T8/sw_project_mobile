import 'package:flutter/material.dart';
import '../../domain/entities/feed_item_entity.dart';

class TrackInfoBox extends StatelessWidget {
  final FeedItemEntity item;

  const TrackInfoBox({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: const Color(0xFF464646),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.track.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.0,
                      backgroundImage: item.track.coverUrl != null
                          ? NetworkImage(item.track.coverUrl!)
                          : null,
                    ),
                    const SizedBox(width: 10.0),

                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              item.track.artistName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          if (item.actor.verified)
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20.0,
                            ),
                          const SizedBox(width: 8.0),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF605E5F),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              item.actor.isFollowing ? 'Following' : 'Follow',
                              style: const TextStyle(fontSize: 15.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}