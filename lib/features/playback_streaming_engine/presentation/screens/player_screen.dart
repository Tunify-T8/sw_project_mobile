import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/playback_status.dart';
import '../providers/player_provider.dart';
import '../widgets/blocked_track_view.dart';
import '../widgets/mini_player.dart';
import '../widgets/player_controls.dart';
import '../widgets/player_waveform_bar.dart';

/// Full-screen player. Pushed on top of the app when a track is loaded.
///
/// Usage:
/// ```dart
/// // Load a track first, then push this screen:
/// ref.read(playerProvider.notifier).loadTrack(trackId);
/// context.push(Routes.player);
/// ```
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: playerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (playerState) {
          if (playerState.bundle == null) {
            return const Center(
              child: Text(
                'No track loaded',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final bundle = playerState.bundle!;

          // Blocked track — show reason instead of player
          if (bundle.playability.isBlocked) {
            return BlockedTrackView(
              blockedReason: bundle.playability.blockedReason,
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Artwork
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        bundle.coverUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white30,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Track info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bundle.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bundle.artist.name,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Like button
                      IconButton(
                        icon: Icon(
                          bundle.engagement.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: bundle.engagement.isLiked
                              ? Colors.orange
                              : Colors.white60,
                        ),
                        onPressed: () {
                          // Engagement actions handled by Module 6 provider
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Waveform / progress bar
                  PlayerWaveformBar(
                    waveformUrl: bundle.waveformUrl,
                    positionSeconds: playerState.positionSeconds,
                    durationSeconds: bundle.durationSeconds,
                    isPreviewOnly: bundle.playability.isPreviewOnly,
                    previewEndSeconds: bundle.preview.previewDurationSeconds,
                    onSeek: (pos) =>
                        ref.read(playerProvider.notifier).seek(pos),
                  ),

                  const SizedBox(height: 8),

                  // Time labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(playerState.positionSeconds),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      if (bundle.playability.isPreviewOnly)
                        const Text(
                          'PREVIEW',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      Text(
                        _formatDuration(bundle.durationSeconds),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Play controls
                  PlayerControls(
                    isPlaying: playerState.isPlaying,
                    hasQueue: playerState.queue != null,
                    onPlay: () => ref.read(playerProvider.notifier).play(),
                    onPause: () => ref.read(playerProvider.notifier).pause(),
                    onNext: () => ref.read(playerProvider.notifier).next(),
                    onPrevious: () =>
                        ref.read(playerProvider.notifier).previous(),
                  ),

                  const SizedBox(height: 24),

                  // Volume row
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          playerState.isMuted
                              ? Icons.volume_off
                              : Icons.volume_down,
                          color: Colors.white60,
                        ),
                        onPressed: () =>
                            ref.read(playerProvider.notifier).toggleMute(),
                      ),
                      Expanded(
                        child: Slider(
                          value: playerState.isMuted ? 0 : playerState.volume,
                          onChanged: (v) =>
                              ref.read(playerProvider.notifier).setVolume(v),
                          activeColor: Colors.orange,
                          inactiveColor: Colors.white24,
                        ),
                      ),
                      const Icon(Icons.volume_up, color: Colors.white60),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
