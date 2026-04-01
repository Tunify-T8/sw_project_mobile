part of 'your_uploads_screen.dart';

extension _YourUploadsScreenActions on _YourUploadsScreenState {
  Future<void> _openFirst(List<UploadItem> items) async {
    final first = items.firstWhere(
      (item) => item.isPlayable,
      orElse: () => items.first,
    );

    await openUploadItemPlayer(context, ref, first, queueItems: items);
  }

  void _handleUploadTap() {
    final callback = widget.onStartUpload;
    if (callback != null) {
      callback();
      return;
    }
    startUploadFlow(context, ref);
  }

  void _openDetail(UploadItem item) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => TrackDetailScreen(item: item)));

  void _showOptions(UploadItem item) {
    showYourUploadsOptionsSheet(
      context,
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
