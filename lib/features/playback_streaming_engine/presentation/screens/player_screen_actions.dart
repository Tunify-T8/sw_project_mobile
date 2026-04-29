part of 'player_screen.dart';

class _BottomActions extends ConsumerWidget {
  const _BottomActions({
    required this.info,
    required this.onQueue,
    required this.onComments,
  });

  final TrackOptionInfo info;
  final VoidCallback onQueue;
  final VoidCallback onComments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackId = info.trackId;
    final state = ref.watch(engagementProvider(trackId));
    final isReposted = state.engagement?.isReposted ?? false;
    final repostCount = state.engagement?.repostCount ?? 0;
    final commentCount = state.engagement?.commentCount ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionBtn(
          icon: Icons.ios_share_outlined,
          label: 'Share',
          onTap: () => showTrackShareSheet(context, info: info, ref: ref),
        ),
        // Key: PlayerKeys.repostButton
        GestureDetector(
          key: const Key('player_repost_button'),
          onTap: () {
            final notifier = ref.read(engagementProvider(trackId).notifier);
            if (isReposted) {
              notifier.removeRepost();
            } else {
              notifier.repostTrack();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isReposted ? Icons.repeat_on : Icons.repeat,
                color: isReposted ? Colors.orange : Colors.white60,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                _fmtCount(repostCount),
                style: TextStyle(
                  color: isReposted ? Colors.orange : Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        // Key: PlayerKeys.commentButton
        GestureDetector(
          key: const Key('player_comment_button'),
          onTap: onComments,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white60,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                _fmtCount(commentCount),
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
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
