import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_status.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/upload_provider.dart';
import '../widgets/metadata/privacy_section.dart';
import '../widgets/metadata/save_metadata_footer.dart';
import '../widgets/metadata/track_file_summary_section.dart';
import '../widgets/metadata/track_info_form_section.dart';
import '../widgets/metadata/track_metadata_tab_switcher.dart';
import '../widgets/metadata/upload_promo_banner.dart';
import '../widgets/sheets/artwork_source_sheet.dart';
import '../widgets/sheets/genre_picker_sheet.dart';
import '../widgets/sheets/track_checklist_sheet.dart';

// refactor again after merging with rozana
class TrackMetadataScreen extends ConsumerStatefulWidget {
  final String trackId;
  final String fileName;

  const TrackMetadataScreen({
    super.key,
    required this.trackId,
    required this.fileName,
  });

  @override
  ConsumerState<TrackMetadataScreen> createState() =>
      _TrackMetadataScreenState();
}

class _TrackMetadataScreenState extends ConsumerState<TrackMetadataScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(trackMetadataProvider.notifier).prepareForNewUpload(
            widget.fileName,
          );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }

    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  String _processingText(UploadStatus status, bool isSaving, bool isPolling) {
    if (isSaving) {
      return 'Preparing to process';
    }

    if (isPolling) {
      return 'Processing';
    }

    switch (status) {
      case UploadStatus.idle:
        return 'Idle';
      case UploadStatus.uploading:
        return 'Uploading';
      case UploadStatus.processing:
        return 'Processing';
      case UploadStatus.finished:
        return 'Finished';
      case UploadStatus.failed:
        return 'Failed';
      case UploadStatus.deleted:
        return 'Deleted';
    }
  }

  Future<void> _handleSave() async {
    final started = await ref
        .read(trackMetadataProvider.notifier)
        .saveMetadataAndProcessInBackground(widget.trackId);

    if (!started || !mounted) {
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final metadataState = ref.watch(trackMetadataProvider);
    final uploadState = ref.watch(uploadProvider);

    _syncController(_titleController, metadataState.title);
    _syncController(_descriptionController, metadataState.description);
    _syncController(_tagsController, metadataState.tagsText);

    final uploadFinished = uploadState.uploadFinished;
    final displayedFileName = uploadState.selectedAudio?.name ?? widget.fileName;
    final buttonEnabled =
        uploadFinished && !metadataState.isSaving && !metadataState.isPolling;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        leadingWidth: 90,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Upload',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => showTrackChecklistSheet(context, metadataState),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: metadataState.checklistProgress,
                      strokeWidth: 3,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFA855F7),
                      ),
                    ),
                    Text(
                      '${metadataState.completedChecklistItems}/4',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const TrackMetadataTabSwitcher(),
          const SizedBox(height: 18),
          const UploadPromoBanner(),
          const SizedBox(height: 18),
          TrackFileSummarySection(
            displayedFileName: displayedFileName,
            artworkPath: metadataState.artworkPath,
            uploadFinished: uploadFinished,
            isPreparingUpload: uploadState.isPreparingUpload,
            isUploading: uploadState.isUploading,
            uploadProgress: uploadState.uploadProgress,
            onPickArtwork: () {
              showArtworkSourceSheet(
                context,
                onPickFromGallery: () {
                  ref.read(trackMetadataProvider.notifier).pickArtwork();
                },
                onPickFromCamera: () {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .pickArtwork(fromCamera: true);
                },
              );
            },
            onReplaceAudio: () {
              ref
                  .read(uploadProvider.notifier)
                  .replaceCurrentAudioAndStartUpload();
            },
          ),
          const SizedBox(height: 22),
          TrackInfoFormSection(
            titleController: _titleController,
            artistController: _artistController,
            descriptionController: _descriptionController,
            tagsController: _tagsController,
            artists: metadataState.artists,
            hasGenre: metadataState.hasGenre,
            selectedGenreLabel: metadataState.selectedGenre.label,
            onTitleChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setTitle(value);
            },
            onAddArtist: (value) {
              ref.read(trackMetadataProvider.notifier).addArtist(value);
            },
            onRemoveArtist: (artist) {
              ref.read(trackMetadataProvider.notifier).removeArtist(artist);
            },
            onGenreTap: () {
              showGenrePickerSheet(
                context,
                selectedGenre: metadataState.selectedGenre,
                onGenreSelected: (genre) {
                  ref.read(trackMetadataProvider.notifier).setGenre(genre);
                },
              );
            },
            onDescriptionChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setDescription(value);
            },
            onTagsChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setTagsText(value);
            },
          ),
          const SizedBox(height: 26),
          PrivacySection(
            currentValue: metadataState.privacy,
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setPrivacy(value);
            },
          ),
          const SizedBox(height: 12),
          SaveMetadataFooter(
            errorMessage: metadataState.error,
            statusText: _processingText(
              metadataState.processingStatus,
              metadataState.isSaving,
              metadataState.isPolling,
            ),
            buttonText: uploadFinished ? 'Save' : 'Uploading...',
            onSavePressed: buttonEnabled ? _handleSave : null,
          ),
        ],
      ),
    );
  }
}