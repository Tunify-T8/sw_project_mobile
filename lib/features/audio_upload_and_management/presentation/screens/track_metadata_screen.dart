// Upload Feature Guide:
// Purpose: Main metadata editor screen used for both new uploads and editing existing tracks.
// Used by: upload_flow_controller, edit_track_screen, upload_entry_screen
// Concerns: Metadata engine.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_item.dart';
import '../controllers/track_metadata_form_controllers.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/track_metadata_tab_provider.dart';
import '../providers/upload_provider.dart';
import '../providers/upload_repository_provider.dart';
import 'track_metadata_screen_utils.dart';
import '../widgets/metadata/save_metadata_footer.dart';
import '../widgets/metadata/track_metadata_body.dart';
import '../widgets/metadata/track_metadata_cancel_dialog.dart';
import '../widgets/metadata/track_metadata_delete_dialog.dart';
import '../widgets/metadata/track_metadata_header.dart';
import '../widgets/sheets/track_checklist_sheet.dart';

class TrackMetadataScreen extends ConsumerStatefulWidget {
  const TrackMetadataScreen({
    super.key,
    required this.trackId,
    required this.fileName,
    this.isEditMode = false,
    this.existingItem,
  });

  final String trackId;
  final String fileName;
  final bool isEditMode;
  final UploadItem? existingItem;

  factory TrackMetadataScreen.edit({Key? key, required UploadItem item}) {
    return TrackMetadataScreen(
      key: key,
      trackId: item.id,
      fileName: item.title,
      isEditMode: true,
      existingItem: item,
    );
  }

  @override
  ConsumerState<TrackMetadataScreen> createState() =>
      _TrackMetadataScreenState();
}

class _TrackMetadataScreenState extends ConsumerState<TrackMetadataScreen> {
  late final TrackMetadataFormControllers _formControllers;

  @override
  void initState() {
    super.initState();
    _formControllers = TrackMetadataFormControllers();
    Future.microtask(() {
      if (widget.isEditMode && widget.existingItem != null) {
        ref
            .read(trackMetadataProvider.notifier)
            .prepareForEdit(widget.existingItem!);
        ref
            .read(uploadProvider.notifier)
            .primeTrackForEditing(trackId: widget.trackId);
      } else {
        ref
            .read(trackMetadataProvider.notifier)
            .prepareForNewUpload(widget.fileName);
      }
    });
  }

  @override
  void dispose() {
    _formControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metadataState = ref.watch(trackMetadataProvider);
    final uploadState = ref.watch(uploadProvider);
    final selectedTab = ref.watch(trackMetadataTabProvider(widget.trackId));
    final tabNotifier = ref.read(
      trackMetadataTabProvider(widget.trackId).notifier,
    );
    final uploadFinished = uploadState.uploadFinished;
    final saveBusy = metadataState.isSaving || metadataState.isPolling;

    _formControllers.sync(metadataState);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TrackMetadataHeader(
              title: widget.isEditMode ? 'Edit track' : 'Upload',
              state: metadataState,
              selectedTab: selectedTab,
              onCancel: _handleCancel,
              onChecklistTap: () =>
                  showTrackChecklistSheet(context, metadataState),
              onTabSelected: tabNotifier.setTab,
            ),
            Expanded(
              child: TrackMetadataBody(
                formControllers: _formControllers,
                state: metadataState,
                selectedTab: selectedTab,
                displayedFileName:
                    uploadState.selectedAudio?.name ?? widget.fileName,
                uploadFinished: uploadFinished,
                isEditMode: widget.isEditMode,
                scheduledReleaseLabel: formatTrackMetadataDate(
                  metadataState.scheduledReleaseDate,
                ),
                onPickReleaseDate: _pickReleaseDate,
                onDelete: _handleDelete,
                onCancelUpload: _handleInlineUploadCancel,
              ),
            ),
            SaveMetadataFooter(
              errorMessage: metadataState.error ?? uploadState.error,
              buttonText: buildTrackMetadataSaveButtonText(
                metadataState,
                isEditMode: widget.isEditMode,
                uploadFinished: uploadFinished,
              ),
              onSavePressed: saveBusy
                  ? null
                  : (widget.isEditMode || uploadFinished ? _handleSave : null),
            ),
          ],
        ),
      ),
    );
  }

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
    final success = widget.isEditMode
        ? await notifier.saveForEdit(widget.trackId)
        : await notifier.saveForNewUpload(widget.trackId);

    if (!success || !mounted) return;

    if (widget.isEditMode) {
      await ref.read(libraryUploadsProvider.notifier).refresh();
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleDelete() async {
    final item = widget.existingItem;
    if (!widget.isEditMode || item == null) return;

    if (await confirmTrackMetadataDeletion(context, item.title)) {
      await ref.read(libraryUploadsProvider.notifier).deleteTrack(item.id);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleCancel() async {
    if (widget.isEditMode) {
      Navigator.of(context).pop();
      return;
    }

    final shouldCancel = await confirmTrackMetadataCancel(context);
    if (!shouldCancel || !mounted) return;

    await ref.read(uploadProvider.notifier).cancelCurrentUpload();

    try {
      await ref.read(uploadRepositoryProvider).deleteTrack(widget.trackId);
    } catch (_) {
      // Best-effort cleanup: still leave the flow if local draft state exists.
    }

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
    } catch (_) {
      // Best-effort cleanup for partially created drafts.
    }

    ref.read(uploadProvider.notifier).discardDraft();
    ref.invalidate(trackMetadataProvider);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
