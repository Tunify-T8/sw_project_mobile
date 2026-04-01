import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../domain/entities/playback_status.dart';
import '../providers/player_provider.dart';
import '../widgets/blocked_track_view.dart';
import '../widgets/player_controls.dart';
import '../widgets/player_waveform_bar.dart';
import 'queue_screen.dart';

/// Full-screen player — pushed on top of the app when a track is loaded.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _artworkController;
  late Animation<double> _artworkScale;
  bool _showMore = false;

  @override
  void initState() {
    super.initState();
    _artworkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _artworkScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _artworkController, curve: Curves.easeOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerState = ref.read(playerProvider).asData?.value;
      if (playerState?.isPlaying == true) _artworkController.forward();
    });
  }

  @override
  void dispose() {
    _artworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider);

    ref.listen<AsyncValue<PlayerState>>(playerProvider, (prev, next) {
      final wasPlaying = prev?.asData?.value?.isPlaying ?? false;
      final isPlaying = next.asData?.value?.isPlaying ?? false;
      if (isPlaying && !wasPlaying) {
        _artworkController.forward();
      } else if (!isPlaying && wasPlaying) {
        _artworkController.reverse();
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: playerAsync.when(
          loading: () => const _PlayerLoading(),
          error: (error, _) => _PlayerError(error: error.toString()),
          data: (playerState) {
            if (playerState.bundle == null) return const _PlayerEmpty();

            final bundle = playerState.bundle!;
            if (bundle.playability.isBlocked) {
              return _BlockedWithNav(
                blockedReason: bundle.playability.blockedReason,
              );
            }

            return _PlayerBody(
              playerState: playerState,
              artworkScale: _artworkScale,
              showMore: _showMore,
              onToggleMore: () => setState(() => _showMore = !_showMore),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main player body
// ---------------------------------------------------------------------------

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

    return Stack(
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
                        positionSeconds: playerState.positionSeconds.round(),
                        durationSeconds: bundle.durationSeconds,
                        isPreviewOnly: bundle.playability.isPreviewOnly,
                        previewStartSeconds: bundle.preview.previewStartSeconds,
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
                        onPlay: () => ref.read(playerProvider.notifier).play(),
                        onPause: () => ref.read(playerProvider.notifier).pause(),
                        onNext: () => ref.read(playerProvider.notifier).next(),
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
    );
  }
}

// ---------------------------------------------------------------------------
// Blurred background
// ---------------------------------------------------------------------------

class _BlurredBackground extends StatelessWidget {
  const _BlurredBackground({required this.coverUrl});
  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          coverUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: const Color(0xFF1A1A1A)),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(color: Colors.black.withOpacity(0.70)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Artwork
// ---------------------------------------------------------------------------

class _Artwork extends StatelessWidget {
  const _Artwork({required this.coverUrl});
  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            coverUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF2A2A2A),
              child: const Icon(
                Icons.music_note,
                color: Colors.white24,
                size: 80,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onDismiss, required this.onMore});
  final VoidCallback onDismiss;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 30),
            color: Colors.white,
            onPressed: onDismiss,
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 24),
            color: Colors.white,
            onPressed: onMore,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Track info row
// ---------------------------------------------------------------------------

class _TrackInfo extends StatelessWidget {
  const _TrackInfo({
    required this.title,
    required this.artistName,
    required this.isLiked,
    required this.onLike,
  });

  final String title;
  final String artistName;
  final bool isLiked;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                artistName,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onLike,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isLiked),
              color: isLiked ? AppColors.primary : Colors.white54,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Time row
// ---------------------------------------------------------------------------

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.positionSeconds,
    required this.durationSeconds,
    required this.isPreviewOnly,
  });

  final double positionSeconds;
  final double durationSeconds;
  final bool isPreviewOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _fmt(positionSeconds),
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        if (isPreviewOnly)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            child: const Text(
              'PREVIEW',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        Text(
          _fmt(durationSeconds),
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  String _fmt(double seconds) {
    final s = seconds.round();
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Volume row
// ---------------------------------------------------------------------------

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({
    required this.volume,
    required this.isMuted,
    required this.onVolumeChanged,
    required this.onToggleMute,
  });

  final double volume;
  final bool isMuted;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onToggleMute;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onToggleMute,
          child: Icon(
            isMuted || volume == 0 ? Icons.volume_off : Icons.volume_down,
            color: Colors.white54,
            size: 20,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
            ),
            child: Slider(
              value: isMuted ? 0 : volume,
              onChanged: onVolumeChanged,
            ),
          ),
        ),
        const Icon(Icons.volume_up, color: Colors.white54, size: 20),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom actions
// ---------------------------------------------------------------------------

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onQueue,
    required this.repostsCount,
    required this.commentsCount,
  });

  final VoidCallback onQueue;
  final int repostsCount;
  final int commentsCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionBtn(icon: Icons.share_outlined, label: 'Share', onTap: () {}),
        _ActionBtn(
          icon: Icons.repeat,
          label: _fmtCount(repostsCount),
          onTap: () {},
        ),
        _ActionBtn(
          icon: Icons.chat_bubble_outline,
          label: _fmtCount(commentsCount),
          onTap: () {},
        ),
        _ActionBtn(icon: Icons.queue_music, label: 'Queue', onTap: onQueue),
      ],
    );
  }

  String _fmtCount(int count) =>
      count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white60, size: 22),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// More options sheet
// ---------------------------------------------------------------------------

class _MoreSheet extends StatelessWidget {
  const _MoreSheet({required this.bundle, required this.onClose});
  final dynamic bundle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _SheetTile(
                  icon: Icons.person_add_outlined,
                  label: 'Go to artist profile',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.playlist_add,
                  label: 'Add to playlist',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.radio,
                  label: 'Start station',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.comment_outlined,
                  label: 'View comments',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.repeat,
                  label: 'Repost on SoundCloud',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.info_outline,
                  label: 'Behind this track',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.flag_outlined,
                  label: 'Report',
                  onTap: onClose,
                  danger: true,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red[400]! : Colors.white;
    return ListTile(
      leading: Icon(icon, color: color.withOpacity(0.8), size: 22),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      dense: true,
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// Blocked with back navigation
// ---------------------------------------------------------------------------

class _BlockedWithNav extends StatelessWidget {
  const _BlockedWithNav({this.blockedReason});
  final BlockedReason? blockedReason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlockedTrackView(blockedReason: blockedReason),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading / error / empty states
// ---------------------------------------------------------------------------

class _PlayerLoading extends StatelessWidget {
  const _PlayerLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _PlayerError extends StatelessWidget {
  const _PlayerError({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 52),
              const SizedBox(height: 16),
              Text(
                error,
                style: const TextStyle(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerEmpty extends StatelessWidget {
  const _PlayerEmpty();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text(
              'No track loaded',
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}