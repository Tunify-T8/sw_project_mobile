part of 'listening_history_screen.dart';

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: Colors.white24, size: 72),
          SizedBox(height: 20),
          Text(
            'No listening history',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tracks you play will appear here',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _AnimatedHistoryList extends StatefulWidget {
  const _AnimatedHistoryList({
    required this.tracks,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onTap,
  });

  final List<HistoryTrack> tracks;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final ValueChanged<HistoryTrack> onTap;

  @override
  State<_AnimatedHistoryList> createState() => _AnimatedHistoryListState();
}

class _AnimatedHistoryListState extends State<_AnimatedHistoryList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  final List<HistoryTrack> _items = <HistoryTrack>[];

  bool _syncing = false;
  bool _needsResync = false;

  @override
  void initState() {
    super.initState();
    _items.addAll(widget.tracks);
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant _AnimatedHistoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameTrackOrder(oldWidget.tracks, widget.tracks)) {
      unawaited(_syncTo(widget.tracks));
    } else {
      for (var index = 0; index < widget.tracks.length && index < _items.length; index++) {
        _items[index] = widget.tracks[index];
      }
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedList(
          key: _listKey,
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 22),
          initialItemCount: _items.length,
          itemBuilder: (context, index, animation) {
            final track = _items[index];
            return SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: _HistoryTrackTile(
                key: ValueKey(track.trackId),
                track: track,
                onTap: () => widget.onTap(track),
              ),
            );
          },
        ),
        if (widget.isLoadingMore)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xAA121212),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final remaining = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (remaining < 220) {
      widget.onLoadMore();
    }
  }

  bool _sameTrackOrder(List<HistoryTrack> a, List<HistoryTrack> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i].trackId != b[i].trackId) return false;
    }

    return true;
  }

  Future<void> _syncTo(List<HistoryTrack> nextTracks) async {
    if (_syncing) {
      _needsResync = true;
      return;
    }

    _syncing = true;

    try {
      // Update items that still exist but changed content.
      final nextById = {
        for (final track in nextTracks) track.trackId: track,
      };
      for (var i = 0; i < _items.length; i++) {
        final updated = nextById[_items[i].trackId];
        if (updated != null) {
          _items[i] = updated;
        }
      }

      // Remove items that no longer exist.
      for (var i = _items.length - 1; i >= 0; i--) {
        final track = _items[i];
        final stillExists = nextTracks.any((item) => item.trackId == track.trackId);
        if (!stillExists) {
          final removed = _items.removeAt(i);
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => SizeTransition(
              sizeFactor: animation,
              child: _HistoryTrackTile(
                track: removed,
                onTap: () => widget.onTap(removed),
              ),
            ),
            duration: const Duration(milliseconds: 220),
          );
        }
      }

      // Reorder / insert so the played track visibly moves to the top.
      for (var targetIndex = 0; targetIndex < nextTracks.length; targetIndex++) {
        final desired = nextTracks[targetIndex];
        final currentIndex = _items.indexWhere(
          (item) => item.trackId == desired.trackId,
        );

        if (currentIndex == -1) {
          _items.insert(targetIndex, desired);
          _listKey.currentState?.insertItem(
            targetIndex,
            duration: const Duration(milliseconds: 260),
          );
          continue;
        }

        _items[currentIndex] = desired;

        if (currentIndex != targetIndex) {
          final moved = _items.removeAt(currentIndex);
          _listKey.currentState?.removeItem(
            currentIndex,
            (context, animation) => SizeTransition(
              sizeFactor: animation,
              child: _HistoryTrackTile(
                track: moved,
                onTap: () => widget.onTap(moved),
              ),
            ),
            duration: const Duration(milliseconds: 220),
          );

          await Future<void>.delayed(const Duration(milliseconds: 70));

          _items.insert(targetIndex, desired);
          _listKey.currentState?.insertItem(
            targetIndex,
            duration: const Duration(milliseconds: 260),
          );
        }
      }

      for (var index = 0; index < nextTracks.length && index < _items.length; index++) {
        _items[index] = nextTracks[index];
      }
    } finally {
      _syncing = false;
      if (_needsResync) {
        _needsResync = false;
        unawaited(_syncTo(widget.tracks));
      }
    }
  }
}

class _TopRefreshOverlay extends StatelessWidget {
  const _TopRefreshOverlay();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xA61A1A1A),
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryTrackTile extends ConsumerWidget {
  const _HistoryTrackTile({
    super.key,
    required this.track,
    required this.onTap,
  });

  final HistoryTrack track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBlocked = track.status == PlaybackStatus.blocked;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: isBlocked ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 64,
                height: 64,
                color: const Color(0xFF96B7FF),
                child: (track.coverUrl?.isNotEmpty == true)
                    ? Image.network(
                        track.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(isBlocked),
                      )
                    : _placeholder(isBlocked),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isBlocked ? Colors.white38 : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.lastPositionSeconds > 0
                        ? 'Stopped at '
                              '${_fmtDuration(track.lastPositionSeconds)} / '
                              '${_fmtDuration(track.durationSeconds)}'
                        : _fmtDuration(track.durationSeconds),
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () async {
                await showTrackOptionsMenu(
                  context: context,
                  trackId: track.trackId,
                  title: track.title,
                  artistId: track.artist.id,
                  artistName: track.artist.name,
                  coverUrl: track.coverUrl,
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.more_horiz, color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(bool isBlocked) {
    return Center(
      child: Icon(
        isBlocked ? Icons.lock : Icons.account_circle_rounded,
        color: isBlocked
            ? Colors.redAccent.withOpacity(0.6)
            : const Color(0xFF4872D7),
        size: 42,
      ),
    );
  }

  String _fmtDuration(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}
