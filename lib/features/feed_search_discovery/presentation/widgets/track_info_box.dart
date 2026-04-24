import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track_preview_entity.dart';
import 'package:software_project/features/profile/presentation/screens/other_user_profile_screen.dart';
import '../../../followers_and_social_graph/presentation/widgets/relationship_button.dart';
import '../utils/feed_track_playback.dart';

class TrackInfoBox extends ConsumerWidget {
  final TrackPreviewEntity track;

  const TrackInfoBox({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Tapping the info box opens the full playback surface for the track.
      // It also stops any active feed preview before launching the player.
      onTap: () => playFeedTrack(context, ref, track),
      child: Container(
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
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OtherUserProfileScreen(userId: track.artistId),
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20.0,
                        backgroundImage: track.artistAvatar != null
                            ? NetworkImage(track.artistAvatar!)
                            : null,
                        child: track.artistAvatar == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
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
                          RelationshipButton(
                            userId: track.artistId,
                            initialIsFollowing: track.isFollowingArtist,
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
      ),
    );
  }
}
