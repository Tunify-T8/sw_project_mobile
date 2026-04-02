part of 'player_screen.dart';

class _PlayerBody extends ConsumerWidget {
  const _PlayerBody({
    required this.playerState,
    required this.artworkScale,
    required this.showMore,
    required this.onToggleMore,
  });

  final PlayerState playerState;
  final Animation<double> artworkScale;
  final bool showMore;
  final VoidCallback onToggleMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundle = playerState.bundle!;

    return GestureDetector(
      // Swipe left → next track, swipe right → previous track
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) async {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -300) {
          await ref.read(playerProvider.notifier).next();
        } else if (velocity > 300) {
          await ref.read(playerProvider.notifier).previous();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _BlurredBackground(coverUrl: bundle.coverUrl),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  onDismiss: () => Navigator.of(context).pop(),
                  onMore: onToggleMore,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 5,
                          child: ScaleTransition(
                            scale: artworkScale,
                            child: _Artwork(coverUrl: bundle.coverUrl),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _TrackInfo(
                          title: bundle.title,
                          artistName: bundle.artist.name,
                          isLiked: bundle.engagement.isLiked,
                          onLike: () {},
                        ),
                        const SizedBox(height: 20),
                        PlayerWaveformBar(
                          waveformUrl: bundle.waveformUrl,
                          // Pass double directly — no .round() — so the bar
                          // animates smoothly at sub-second resolution and
                          // reaches exactly 1.0 when the track finishes.
                          positionSeconds: playerState.positionSeconds,
                          durationSeconds: bundle.durationSeconds,
                          isPreviewOnly: bundle.playability.isPreviewOnly,
                          previewStartSeconds:
                              bundle.preview.previewStartSeconds,
                          previewDurationSeconds:
                              bundle.preview.previewDurationSeconds,
                          onSeek: (pos) =>
                              ref.read(playerProvider.notifier).seek(pos),
                        ),
                        const SizedBox(height: 6),
                        _TimeRow(
                          positionSeconds: playerState.positionSeconds,
                          durationSeconds: bundle.durationSeconds.toDouble(),
                          isPreviewOnly: bundle.playability.isPreviewOnly,
                        ),
                        const SizedBox(height: 20),
                        PlayerControls(
                          isPlaying: playerState.isPlaying,
                          hasQueue: playerState.queue != null,
                          onPlay: () =>
                              ref.read(playerProvider.notifier).play(),
                          onPause: () =>
                              ref.read(playerProvider.notifier).pause(),
                          onNext: () =>
                              ref.read(playerProvider.notifier).next(),
                          onPrevious: () =>
                              ref.read(playerProvider.notifier).previous(),
                        ),
                        const SizedBox(height: 20),
                        _VolumeRow(
                          volume: playerState.volume,
                          isMuted: playerState.isMuted,
                          onVolumeChanged: (v) =>
                              ref.read(playerProvider.notifier).setVolume(v),
                          onToggleMute: () =>
                              ref.read(playerProvider.notifier).toggleMute(),
                        ),
                        const SizedBox(height: 16),
                        _BottomActions(
                          onQueue: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const QueueScreen(),
                              ),
                            );
                          },
                          repostsCount: bundle.engagement.repostCount,
                          commentsCount: bundle.engagement.commentCount,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showMore) _MoreSheet(bundle: bundle, onClose: onToggleMore),
        ],
      ),
    );
  }
}