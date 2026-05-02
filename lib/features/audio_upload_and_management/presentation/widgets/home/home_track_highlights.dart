import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/upload_item.dart';
import '../../providers/home_tracks_provider.dart';
import '../upload_artwork_view.dart';

class HomeTrackHighlights extends ConsumerWidget {
  const HomeTrackHighlights({
    super.key,
    required this.onOpenTrack,
    required this.onSeeAll,
  });

  final void Function(UploadItem item, List<UploadItem> queue) onOpenTrack;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(homeTracksProvider);

    return tracksAsync.when(
      data: (tracks) {
        if (tracks.isEmpty) return const SizedBox.shrink();
        final previewTracks = tracks.take(10).toList(growable: false);
        final queue = tracks.map((item) => item.track).toList(growable: false);
        final dailyPick = _pickForToday(tracks);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MoreLikeThisSection(
              tracks: previewTracks,
              queue: queue,
              onOpenTrack: onOpenTrack,
              onSeeAll: onSeeAll,
            ),
            if (dailyPick != null) ...[
              const SizedBox(height: 34),
              _TodayPickSection(
                track: dailyPick,
                queue: queue,
                onOpenTrack: onOpenTrack,
              ),
            ],
          ],
        );
      },
      loading: () => const _HighlightsSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _MoreLikeThisSection extends StatelessWidget {
  const _MoreLikeThisSection({
    required this.tracks,
    required this.queue,
    required this.onOpenTrack,
    required this.onSeeAll,
  });

  final List<HomeTrackItem> tracks;
  final List<UploadItem> queue;
  final void Function(UploadItem item, List<UploadItem> queue) onOpenTrack;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth < 390 ? 140.0 : 154.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 26, 18, 14),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'More of what you like',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: cardWidth + 86,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: tracks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final track = tracks[index];
              return _HomeTrackPoster(
                track: track.track,
                width: cardWidth,
                onTap: () => onOpenTrack(track.track, queue),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TodayPickSection extends StatelessWidget {
  const _TodayPickSection({
    required this.track,
    required this.queue,
    required this.onOpenTrack,
  });

  final HomeTrackItem track;
  final List<UploadItem> queue;
  final void Function(UploadItem item, List<UploadItem> queue) onOpenTrack;

  @override
  Widget build(BuildContext context) {
    final upload = track.track;
    final likeCount = track.likesCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY'S PICK",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hot For You \u{1F525}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onOpenTrack(upload, queue),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF242424),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  UploadArtworkView(
                    localPath: upload.localArtworkPath,
                    remoteUrl: upload.artworkUrl,
                    width: 86,
                    height: 86,
                    borderRadius: BorderRadius.circular(8),
                    placeholder: const Icon(
                      Icons.music_note,
                      color: Colors.white30,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          upload.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          upload.artistDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                        ),
                        if (likeCount != null) ...[
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Colors.white70,
                                size: 21,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${_formatCount(likeCount)} people just liked this track',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: FilledButton(
                      onPressed: () => onOpenTrack(upload, queue),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, size: 38),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeAllTracksView extends ConsumerWidget {
  const HomeAllTracksView({
    super.key,
    required this.onBack,
    required this.onOpenTrack,
  });

  final VoidCallback onBack;
  final void Function(UploadItem item, List<UploadItem> queue) onOpenTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(homeTracksProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: tracksAsync.when(
          data: (tracks) {
            final queue = tracks
                .map((item) => item.track)
                .toList(growable: false);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 48),
                    child: _BackCircleButton(onPressed: onBack),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, 0, 18, 24),
                    child: Text(
                      'More of what you like',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                if (tracks.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No tracks found',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 150),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 28,
                        crossAxisSpacing: 26,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final track = tracks[index].track;
                          return _HomeTrackPoster(
                            track: track,
                            width: double.infinity,
                            onTap: () => onOpenTrack(track, queue),
                          );
                        },
                        childCount: tracks.length,
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 48),
                  child: _BackCircleButton(onPressed: onBack),
                ),
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Could not load tracks',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTrackPoster extends StatelessWidget {
  const _HomeTrackPoster({
    required this.track,
    required this.width,
    required this.onTap,
  });

  final UploadItem track;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: UploadArtworkView(
                localPath: track.localArtworkPath,
                remoteUrl: track.artworkUrl,
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(4),
                placeholder: const Icon(
                  Icons.graphic_eq,
                  color: Colors.white24,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              track.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              track.artistDisplay,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: IconButton.filled(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFF202020),
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    );
  }
}

class _HighlightsSkeleton extends StatelessWidget {
  const _HighlightsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'More of what you like',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 20),
              itemBuilder: (_, _) => Container(
                width: 154,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

HomeTrackItem? _pickForToday(List<HomeTrackItem> tracks) {
  final likedTracks = tracks
      .where((track) => (track.likesCount ?? 0) > 0)
      .toList(growable: false);
  if (likedTracks.isEmpty) return null;

  final today = DateTime.now();
  final seed = today.year * 10000 + today.month * 100 + today.day + 97;
  var selected = likedTracks.first;
  var selectedRank = _dailyRank(selected.track.id, seed);

  for (final track in likedTracks.skip(1)) {
    final rank = _dailyRank(track.track.id, seed);
    if (rank < selectedRank) {
      selected = track;
      selectedRank = rank;
    }
  }

  return selected;
}

String _formatCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}

int _dailyRank(String value, Object seed) {
  var hash = seed.hashCode & 0x3fffffff;
  for (final unit in value.codeUnits) {
    hash = ((hash * 37) + unit) & 0x3fffffff;
  }
  return hash;
}
