import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../engagements_social_interactions/domain/entities/liked_track_entity.dart';
import '../../../../engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../../engagements_social_interactions/presentation/screens/liked_tracks_screen.dart';
import '../../../domain/entities/upload_item.dart';
import '../../utils/upload_player_launcher.dart';

class HomeLikesTile extends ConsumerStatefulWidget {
  const HomeLikesTile({super.key});

  @override
  ConsumerState<HomeLikesTile> createState() => _HomeLikesTileState();
}

class _HomeLikesTileState extends ConsumerState<HomeLikesTile> {
  bool _isShuffling = false;

  Future<void> _shuffleLikes() async {
    if (_isShuffling) return;
    setState(() => _isShuffling = true);

    try {
      final likedTracks = await ref
          .read(getLikedTracksUsecaseProvider)
          .call(viewerId: '');
      final queue = likedTracks
          .map(_likedTrackToUploadItem)
          .where((track) => track.isPlayable)
          .toList(growable: false);

      if (!mounted) return;
      if (queue.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No liked tracks to play yet.')),
        );
        return;
      }

      final selected = queue[Random().nextInt(queue.length)];
      await openUploadItemPlayer(
        context,
        ref,
        selected,
        queueItems: queue,
        openScreen: false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not play your likes right now.')),
      );
    } finally {
      if (mounted) setState(() => _isShuffling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        key: const Key('home_your_likes_tile'),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LikedTracksScreen()));
        },
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3F1004), Color(0xFF2F1A14), Color(0xFF211E1D)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.favorite_border,
                color: Color(0xFFE1370F),
                size: 32,
              ),

              const SizedBox(width: 16),

              const Expanded(
                child: Text(
                  'Your likes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: _isShuffling
                    ? const Padding(
                        padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.shuffle),
                        color: Colors.grey,
                        onPressed: _shuffleLikes,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

UploadItem _likedTrackToUploadItem(LikedTrackEntity track) {
  return UploadItem(
    id: track.trackId,
    title: track.title,
    artistDisplay: track.artistName.trim().isEmpty
        ? 'SoundCloud'
        : track.artistName,
    durationLabel: _formatDuration(track.duration),
    durationSeconds: track.duration,
    artworkUrl: track.coverUrl ?? track.artistAvatar,
    visibility: UploadVisibility.public,
    status: UploadProcessingStatus.finished,
    isExplicit: false,
    createdAt: track.likedAt,
  );
}

String _formatDuration(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = safe ~/ 60;
  final seconds = (safe % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
