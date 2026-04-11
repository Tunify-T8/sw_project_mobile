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

class _CommentComposerBar extends StatelessWidget {
  const _CommentComposerBar();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onMoreTap,
    required this.onQueueTap,
  });

  final VoidCallback onMoreTap;
  final VoidCallback onQueueTap;

  @override
  Widget build(BuildContext context) {
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
            const _ActionMetric(icon: Icons.favorite_border, label: '36K'),
            const _ActionMetric(icon: Icons.chat_bubble_outline, label: '191'),
            const _ActionMetric(icon: Icons.ios_share_outlined, label: ''),
            _ActionMetric(
              icon: Icons.playlist_play,
              label: '',
              onTap: onQueueTap,
            ),
            _ActionMetric(
              icon: Icons.more_horiz,
              label: '',
              onTap: onMoreTap,
            ),
          ],
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
