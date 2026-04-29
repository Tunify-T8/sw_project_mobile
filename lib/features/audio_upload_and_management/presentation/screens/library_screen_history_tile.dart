part of 'library_screen.dart';

const double _libraryHistoryTileExtent = 92;

class _AnimatedLibraryHistoryPreview extends StatefulWidget {
  const _AnimatedLibraryHistoryPreview({
    required this.tracks,
    required this.queueTracks,
  });

  final List<HistoryTrack> tracks;
  final List<HistoryTrack> queueTracks;

  @override
  State<_AnimatedLibraryHistoryPreview> createState() =>
      _AnimatedLibraryHistoryPreviewState();
}

class _AnimatedLibraryHistoryPreviewState
    extends State<_AnimatedLibraryHistoryPreview> {
  late List<HistoryTrack> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = List<HistoryTrack>.from(widget.tracks);
  }

  @override
  void didUpdateWidget(covariant _AnimatedLibraryHistoryPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameTrackOrder(oldWidget.tracks, widget.tracks)) {
      setState(() {
        _tracks = List<HistoryTrack>.from(widget.tracks);
      });
      return;
    }

    for (var i = 0; i < widget.tracks.length && i < _tracks.length; i++) {
      _tracks[i] = widget.tracks[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleCount = _tracks.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
      child: SizedBox(
        height: visibleCount * _libraryHistoryTileExtent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var index = 0; index < _tracks.length; index++)
              AnimatedPositioned(
                key: ValueKey(_tracks[index].trackId),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                left: 0,
                right: 0,
                top: index * _libraryHistoryTileExtent,
                height: _libraryHistoryTileExtent,
                child: _LibraryHistoryTile(
                  track: _tracks[index],
                  queueTracks: widget.queueTracks,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _sameTrackOrder(List<HistoryTrack> a, List<HistoryTrack> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].trackId != b[i].trackId) return false;
    }
    return true;
  }
}

class _LibraryHistoryTile extends ConsumerWidget {
  const _LibraryHistoryTile({required this.track, required this.queueTracks});

  final HistoryTrack track;
  final List<HistoryTrack> queueTracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(globalTrackStoreProvider);
    final stored = storedUploadItemForTrack(store, track.trackId);
    final isBlocked = track.status == PlaybackStatus.blocked;

    return SizedBox(
      height: _libraryHistoryTileExtent,
      child: GestureDetector(
        onTap: isBlocked
            ? null
            : () async {
                final playableHistory = queueTracks
                    .where((item) => item.status != PlaybackStatus.blocked)
                    .toList(growable: false);
                final selected = _historyTrackToUploadItem(track, stored);

                await openHistorySourcedPlayer(
                  context,
                  ref,
                  selected,
                  historyTracks: playableHistory,
                  openScreen: true,
                  initialPositionSeconds:
                      track.lastPositionSeconds.toDouble(),
                );
              },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                          errorBuilder: (_, error, stackTrace) =>
                              _placeholder(isBlocked),
                        )
                      : _placeholder(isBlocked),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDuration(track.durationSeconds),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      print(track.artist.id);
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
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.white54,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  UploadItem _historyTrackToUploadItem(HistoryTrack track, UploadItem? stored) {
    if (stored != null) {
      return stored;
    }

    return UploadItem(
      id: track.trackId,
      title: track.title,
      artistDisplay: track.artist.name,
      durationLabel: _formatDuration(track.durationSeconds),
      durationSeconds: track.durationSeconds,
      audioUrl: null,
      waveformUrl: null,
      artworkUrl: track.coverUrl,
      localFilePath: null,
      description: '',
      visibility: UploadVisibility.public,
      status: UploadProcessingStatus.finished,
      isExplicit: false,
      createdAt: track.playedAt,
    );
  }

  String _formatDuration(int totalSeconds) {
    final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = safeSeconds ~/ 60;
    final seconds = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _placeholder(bool isBlocked) {
    return Center(
      child: Icon(
        isBlocked ? Icons.lock : Icons.account_circle_rounded,
        color: isBlocked
            ? Colors.redAccent.withValues(alpha: 0.6)
            : const Color(0xFF4872D7),
        size: 52,
      ),
    );
  }
}
