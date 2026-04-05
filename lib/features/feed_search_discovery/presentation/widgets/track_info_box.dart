import 'package:flutter/material.dart';
import '../../domain/entities/track_preview_entity.dart';

class TrackInfoBox extends StatelessWidget {
  final TrackPreviewEntity track;

  const TrackInfoBox({super.key, required this.track});

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
                  track.title,
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
                      backgroundImage: track.coverUrl != null
                          ? NetworkImage(track.coverUrl!)
                          : null,
                    ),
                    const SizedBox(width: 10.0),

                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              track.artistName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          if (track.artistVerified)
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
                               (track.isFollowingArtist ?? true) ?'Following' : 'Follow',
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