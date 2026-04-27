part of 'track_info_screen.dart';

class _MainTrackCard extends ConsumerWidget {
  const _MainTrackCard({required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider).asData?.value;
    final isCurrentTrack = playerState?.bundle?.trackId == item.id;
    final isPlaying = isCurrentTrack && playerState?.isPlaying == true;
    final stats = _MockTrackStats.fromItem(item);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AnimatedTrackAvatar(item: item, isPlaying: isPlaying),
              const SizedBox(width: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.profile),
                        child: Text(
                          item.artistDisplay,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${item.durationLabel}  ${stats.releaseDateText}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 26),
                child: GestureDetector(
                  onTap: () => toggleUploadItemPlayback(ref, item),
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _MetricIconText(
                icon: Icons.favorite_border,
                text: stats.likeCountText,
              ),
              const SizedBox(width: 28),
              _MetricIconText(
                icon: Icons.chat_bubble_outline,
                text: stats.commentCountText,
              ),
              const SizedBox(width: 28),
              _MetricIconText(icon: Icons.repeat, text: stats.repostCountText),
              const SizedBox(width: 28),
              GestureDetector(
                onTap: () async {
                  // Track info page is reached from many paths (feed, search,
                  // history, own uploads). Resolve ownership and artist id
                  // via the shared lookup so the sheet shows the right
                  // layout regardless of how we got here.
                  final bundle = ref.read(playerProvider).asData?.value.bundle;
                  final artistId =
                      (bundle?.trackId == item.id &&
                          bundle!.artist.id.trim().isNotEmpty)
                      ? bundle.artist.id
                      : null;
                  await showTrackOptionsMenu(
                    context: context,
                    trackId: item.id,
                    title: item.title,
                    artistId: artistId ?? '',
                    artistName: item.artistDisplay,
                    coverUrl: item.artworkUrl,
                    isBehindTrack: true,
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
