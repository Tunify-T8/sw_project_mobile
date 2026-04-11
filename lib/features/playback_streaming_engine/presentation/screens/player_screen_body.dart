part of 'player_screen.dart';

class _PlayerBody extends ConsumerWidget {
  const _PlayerBody({
    required this.playerState,
    required this.artworkScale,
    required this.showMore,
    required this.swipeDir,
    required this.onToggleMore,
    required this.onSwipeNext,
    required this.onSwipePrevious,
  });

  final PlayerState playerState;
  final Animation<double> artworkScale;
  final bool showMore;

  /// Direction of the most recent swipe: 1 = next, -1 = previous, 0 = none.
  /// Used by AnimatedSwitcher to choose the slide direction.
  final int swipeDir;

  final VoidCallback onToggleMore;
  final VoidCallback onSwipeNext;
  final VoidCallback onSwipePrevious;

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
          onSwipeNext();
          await ref.read(playerProvider.notifier).next();
        } else if (velocity > 300) {
          onSwipePrevious();
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
                        // Track-specific content (artwork + info + waveform).
                        // AnimatedSwitcher slides+fades when bundle.trackId changes.
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            // StackFit.expand gives _TrackContent tight constraints
                            // so the Expanded(flex: 5) inside its Column works.
                            layoutBuilder: (currentChild, previousChildren) =>
                                Stack(
                              fit: StackFit.expand,
                              alignment: Alignment.center,
                              children: [
                                ...previousChildren,
                                if (currentChild case final child?) child,
                              ],
                            ),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: animation.drive(
                                  Tween(
                                    begin: Offset(swipeDir.toDouble() * 0.25, 0),
                                    end: Offset.zero,
                                  ).chain(CurveTween(curve: Curves.easeOut)),
                                ),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: _TrackContent(
                              key: ValueKey(bundle.trackId),
                              playerState: playerState,
                              artworkScale: artworkScale,
                              onSeek: (pos) =>
                                  ref.read(playerProvider.notifier).seek(pos),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _TrackInfo(
                          title: bundle.title,
                          artistName: bundle.artist.name,
                          isLiked: isLiked,
                          onLike: () => ref
                              .read(engagementProvider(bundle.trackId).notifier)
                              .toggleLike(),
                          likeCount: engagementState.engagement?.likeCount ?? 0,
                          onLikeCountTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LikersScreen(trackId: bundle.trackId),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        PlayerWaveformBar(
                          waveformUrl: bundle.waveformUrl,
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
                          isShuffle: playerState.queue?.shuffle ?? false,
                          repeatMode: switch (playerState.queue?.repeat) {
                            RepeatMode.one => 1,
                            RepeatMode.all => 2,
                            _ => 0,
                          },
                          onPlay: () =>
                              ref.read(playerProvider.notifier).play(),
                          onPause: () =>
                              ref.read(playerProvider.notifier).pause(),
                          onNext: () =>
                              ref.read(playerProvider.notifier).next(),
                          onPrevious: () =>
                              ref.read(playerProvider.notifier).previous(),
                          onShuffle: () =>
                              ref.read(playerProvider.notifier).toggleShuffle(),
                          onRepeat: () =>
                              ref.read(playerProvider.notifier).toggleRepeat(),
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

/// Artwork + track info + waveform bar + time row for one track.
/// Keyed by [bundle.trackId] so AnimatedSwitcher can animate between tracks.
class _TrackContent extends ConsumerWidget { // engagement modification — was StatelessWidget, converted to ConsumerWidget
  const _TrackContent({
    super.key,
    required this.playerState,
    required this.artworkScale,
    required this.onSeek,
  });

  final PlayerState playerState;
  final Animation<double> artworkScale;
  final void Function(int positionSeconds) onSeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) { // engagement modification — added WidgetRef ref
    final bundle = playerState.bundle!;
    final engagementState = ref.watch(engagementProvider(bundle.trackId)); // engagement modification — watch live engagement state
    final isLiked = engagementState.engagement?.isLiked ?? bundle.engagement.isLiked; // engagement modification — prefer live state over stale bundle
    final likeCount = engagementState.engagement?.likeCount ?? bundle.engagement.likeCount; // engagement modification — prefer live state over stale bundle
    return Column(
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
          isLiked: isLiked, // engagement modification — was bundle.engagement.isLiked
          onLike: () => ref.read(engagementProvider(bundle.trackId).notifier).toggleLike(), // engagement modification — was () {}
          likeCount: likeCount, // engagement modification — added
          onLikeCountTap: () => Navigator.of(context).push( // engagement modification — added, navigates to LikersScreen
            MaterialPageRoute(
              builder: (_) => LikersScreen(trackId: bundle.trackId),
            ),
          ),
        ),
        const SizedBox(height: 20),
        PlayerWaveformBar(
          waveformUrl: bundle.waveformUrl,
          positionSeconds: playerState.positionSeconds,
          durationSeconds: bundle.durationSeconds,
          isPreviewOnly: bundle.playability.isPreviewOnly,
          previewStartSeconds: bundle.preview.previewStartSeconds,
          previewDurationSeconds: bundle.preview.previewDurationSeconds,
          onSeek: onSeek,
        ),
        const SizedBox(height: 6),
        _TimeRow(
          positionSeconds: playerState.positionSeconds,
          durationSeconds: bundle.durationSeconds.toDouble(),
          isPreviewOnly: bundle.playability.isPreviewOnly,
        ),
      ],
    );
  }
}
