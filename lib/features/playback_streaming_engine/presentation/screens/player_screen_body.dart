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
    final engagementState = ref.watch(engagementProvider(bundle.trackId)); // engagement addition — watch live engagement state for this track
    final isLiked =
        engagementState.engagement?.isLiked ?? bundle.engagement.isLiked; // engagement addition — prefer engagementProvider over stale bundle value

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
                          isLiked: isLiked, // engagement modification — was bundle.engagement.isLiked, now uses reactive isLiked above
                          onLike: () => ref
                              .read(engagementProvider(bundle.trackId).notifier)
                              .toggleLike(),
                          likeCount: engagementState.engagement?.likeCount ?? 0, // engagement addition
                          onLikeCountTap: () => Navigator.of(context).push( // engagement addition — open LikersScreen on count tap
                            MaterialPageRoute(
                              builder: (_) => LikersScreen(trackId: bundle.trackId),
                            ),
                          ),
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
                          trackId: bundle.trackId,
                          onQueue: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const QueueScreen(),
                              ),
                            );
                          },
                          onComments: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CommentsScreen(
                                  trackId: bundle.trackId,
                                ),
                              ),
                            );
                          },
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