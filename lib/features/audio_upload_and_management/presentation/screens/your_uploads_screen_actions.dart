part of 'your_uploads_screen.dart';

extension _YourUploadsScreenActions on _YourUploadsScreenState {
  /// Opens the first playable track and starts the full uploads queue.
  Future<void> _openFirst(List<UploadItem> items) async {
    final playable = _playableUploads(items);
    if (playable.isEmpty) return;

    await openUploadItemPlayer(
      context,
      ref,
      playable.first,
      queueItems: playable,
      openScreen: false,
    );
  }

  /// Opens a random playable upload and keeps the user on this screen.
  Future<void> _openRandom(List<UploadItem> items) async {
    final playable = _playableUploads(items);
    if (playable.isEmpty) return;
    final selected = playable[Random().nextInt(playable.length)];

    await openUploadItemPlayer(
      context,
      ref,
      selected,
      queueItems: playable,
      openScreen: false,
    );
  }

  List<UploadItem> _playableUploads(List<UploadItem> items) {
    return items
        .where((item) => item.isPlayable && !item.isDeleted)
        .toList(growable: false);
  }

  /// Tapping any tile in the uploads list should:
  ///   1. Start playing the track immediately (with the full uploads queue)
  ///   2. Open the track detail surface (which syncs to the playing track)
  ///
  /// Previously this called Navigator.push(TrackDetailScreen) directly, which
  /// skipped playback and opened the screen paused.
  Future<void> _openDetail(UploadItem item) async {
    final state = ref.read(libraryUploadsProvider);
    final allPlayable = state.filteredItems;

    await openUploadItemPlayer(
      context,
      ref,
      item,
      queueItems: allPlayable.isNotEmpty ? allPlayable : null,
      openScreen: true,
    );
  }

  void _handleUploadTap() {
    final callback = widget.onStartUpload;
    if (callback != null) {
      callback();
      return;
    }
    startUploadFlow(context, ref);
  }

  void _showOptions(UploadItem item) {
    showYourUploadsOptionsSheet(
      context,
      ref: ref,
      item: item,
      onEditTap: () {
        Navigator.pop(context);
        Navigator.of(context)
            .push(
              MaterialPageRoute(builder: (_) => EditTrackScreen(item: item)),
            )
            .then((result) {
              if (result == true) {
                ref.read(libraryUploadsProvider.notifier).refresh();
              }
            });
      },
      onDeleteTap: () {
        Navigator.pop(context);
        _deleteTrack(item);
      },
    );
  }

  Future<void> _deleteTrack(UploadItem item) async =>
      await confirmYourUploadsDeletion(context, item)
      ? ref.read(libraryUploadsProvider.notifier).deleteTrack(item.id)
      : Future<void>.value();
}
