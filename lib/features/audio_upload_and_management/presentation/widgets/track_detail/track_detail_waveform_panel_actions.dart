part of 'track_detail_waveform_panel.dart';

class _PauseCircleButton extends StatelessWidget {
  const _PauseCircleButton({
    required this.icon,
    required this.onTap,
    this.size = 74,
    this.iconSize = 42,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.82),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}

class _WaveformCommentBubble extends StatelessWidget {
  const _WaveformCommentBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white70, size: 18),
        ),
        const SizedBox(width: 10),
        Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade600.withOpacity(0.72),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// engagement addition — tapping opens CommentsScreen for this track
// advise to remove: replaced by CommentInputBar in track_detail_waveform_panel.dart
class _CommentComposerBar extends StatelessWidget {
  const _CommentComposerBar({
    required this.trackId,
    this.coverUrl,
    this.trackTitle,
    this.artistName,
  });

  final String trackId;
  final String? coverUrl;
  final String? trackTitle;
  final String? artistName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CommentsScreen(
            trackId: trackId,
            coverUrl: coverUrl,
            trackTitle: trackTitle,
            artistName: artistName,
          ),
        ),
      ),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade700.withOpacity(0.68),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'Comment...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 24),
            SizedBox(width: 12),
            Icon(Icons.send_rounded, color: Colors.white70, size: 22),
          ],
        ),
      ),
    );
  }
}

// engagement addition — like/comment counts and actions driven by engagementProvider
class _BottomActionBar extends ConsumerStatefulWidget {
  const _BottomActionBar({
    required this.trackId,
    required this.onMoreTap,
    required this.onQueueTap,
    this.coverUrl,
    this.trackTitle,
    this.artistName,
  });

  final String trackId;
  final VoidCallback onMoreTap;
  final VoidCallback onQueueTap;
  final String? coverUrl;
  final String? trackTitle;
  final String? artistName;

  @override
  ConsumerState<_BottomActionBar> createState() => _BottomActionBarState();
}

class _BottomActionBarState extends ConsumerState<_BottomActionBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(engagementProvider(widget.trackId));
      if (state.engagementStatus == EngagementStatus.initial) {
        ref.read(engagementProvider(widget.trackId).notifier).loadEngagement();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(engagementProvider(widget.trackId));
    final isLiked = state.engagement?.isLiked ?? false;
    final likeCount = state.engagement?.likeCount ?? 0;
    final commentCount = state.engagement?.commentCount ?? 0;

    // Wrap in a GestureDetector that absorbs all taps in this row so the
    // full-screen background play/pause detector cannot steal them.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // absorb — individual buttons handle their own taps
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Like button — tapping icon toggles like, tapping count opens likers
            _LikeMetric(
              trackId: widget.trackId,
              isLiked: isLiked,
              likeCount: likeCount,
            ),
            // Comment button — opens CommentsScreen
            _ActionMetric(
              icon: Icons.chat_bubble_outline,
              label: _fmtCount(commentCount),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CommentsScreen(
                    trackId: widget.trackId,
                    coverUrl: widget.coverUrl,
                    trackTitle: widget.trackTitle,
                    artistName: widget.artistName,
                  ),
                ),
              ),
            ),
            const _ActionMetric(icon: Icons.ios_share_outlined, label: ''),
            _ActionMetric(
              icon: Icons.playlist_play,
              label: '',
              onTap: widget.onQueueTap,
            ),
            _ActionMetric(
              icon: Icons.more_horiz,
              label: '',
              onTap: widget.onMoreTap,
            ),
          ],
        ),
      ),
    );
  }

  String _fmtCount(int count) =>
      count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';
}

// engagement addition — like icon + count as a single tappable group
class _LikeMetric extends ConsumerWidget {
  const _LikeMetric({
    required this.trackId,
    required this.isLiked,
    required this.likeCount,
  });

  final String trackId;
  final bool isLiked;
  final int likeCount;

  String _fmtCount(int count) =>
      count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => ref
                    .read(engagementProvider(trackId).notifier)
                    .toggleLike(),
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white,
                  size: 29,
                ),
              ),
              if (likeCount > 0) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LikersScreen(trackId: trackId),
                    ),
                  ),
                  child: Text(
                    _fmtCount(likeCount),
                    style: TextStyle(
                      color: isLiked ? Colors.red : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionMetric extends StatelessWidget {
  const _ActionMetric({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Minimum 44×44 touch target as per Material guidelines.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 29),
                if (label.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
