part of 'player_screen.dart';

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
