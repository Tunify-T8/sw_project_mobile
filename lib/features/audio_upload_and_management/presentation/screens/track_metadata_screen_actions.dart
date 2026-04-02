part of 'track_metadata_screen.dart';

extension _TrackMetadataScreenActions on _TrackMetadataScreenState {
  Future<void> _pickReleaseDate() async {
    final state = ref.read(trackMetadataProvider);
    final selected = await showDatePicker(
      context: context,
      initialDate: state.scheduledReleaseDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (_, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (selected != null) {
      ref
          .read(trackMetadataProvider.notifier)
          .setScheduledReleaseDate(selected);
    }
  }

  Future<void> _handleSave() async {
    final notifier = ref.read(trackMetadataProvider.notifier);
    final existingItem = widget.existingItem;

    final success = widget.isEditMode
        ? await notifier.saveForEdit(widget.trackId)
        : await notifier.saveForNewUpload(widget.trackId);

    if (!success || !mounted) return;

    if (widget.isEditMode) {
      if (existingItem != null) {
        ref.invalidate(trackDetailItemProvider(existingItem));
        ref.invalidate(trackDetailWaveformProvider(existingItem));
      }

      await ref.read(libraryUploadsProvider.notifier).refresh();
    }

    ref.invalidate(trackMetadataProvider);

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleDelete() async {
    final item = widget.existingItem;
    if (!widget.isEditMode || item == null) return;

    if (await confirmTrackMetadataDeletion(context, item.title)) {
      ref.invalidate(trackDetailItemProvider(item));
      ref.invalidate(trackDetailWaveformProvider(item));
      await ref.read(libraryUploadsProvider.notifier).deleteTrack(item.id);
      ref.invalidate(trackMetadataProvider);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleCancel() async {
    if (widget.isEditMode) {
      ref.invalidate(trackMetadataProvider);
      Navigator.of(context).pop();
      return;
    }

    final shouldCancel = await confirmTrackMetadataCancel(context);
    if (!shouldCancel || !mounted) return;

    await ref.read(uploadProvider.notifier).cancelCurrentUpload();

    try {
      await ref.read(uploadRepositoryProvider).deleteTrack(widget.trackId);
    } catch (_) {}

    ref.read(uploadProvider.notifier).discardDraft();
    ref.invalidate(trackMetadataProvider);

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _handleInlineUploadCancel() async {
    final shouldCancel = await confirmTrackMetadataCancel(context);
    if (!shouldCancel || !mounted) return;

    final restoredPreviousUpload = await ref
        .read(uploadProvider.notifier)
        .cancelCurrentUpload();
    if (restoredPreviousUpload || widget.isEditMode || !mounted) return;

    try {
      await ref.read(uploadRepositoryProvider).deleteTrack(widget.trackId);
    } catch (_) {}

    ref.read(uploadProvider.notifier).discardDraft();
    ref.invalidate(trackMetadataProvider);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
