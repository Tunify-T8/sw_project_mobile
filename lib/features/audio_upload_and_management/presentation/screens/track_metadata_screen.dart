import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_item.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/track_metadata_state.dart';
import '../providers/upload_provider.dart';
import '../widgets/metadata/advanced_metadata_section.dart';
import '../widgets/metadata/permissions_metadata_section.dart';
import '../widgets/metadata/privacy_section.dart';
import '../widgets/metadata/save_metadata_footer.dart';
import '../widgets/metadata/track_file_summary_section.dart';
import '../widgets/metadata/track_info_form_section.dart';
import '../widgets/metadata/track_metadata_tab_switcher.dart';
import '../widgets/metadata/upload_metadata_tab.dart';
import '../widgets/metadata/upload_promo_banner.dart';
import '../widgets/sheets/artwork_source_sheet.dart';
import '../widgets/sheets/genre_picker_sheet.dart';
import '../widgets/sheets/track_checklist_sheet.dart';
import '../widgets/upload_checklist_progress_ring.dart';

class TrackMetadataScreen extends ConsumerStatefulWidget {
  final String trackId;
  final String fileName;
  final bool isEditMode;
  final UploadItem? existingItem;

  const TrackMetadataScreen({
    super.key,
    required this.trackId,
    required this.fileName,
    this.isEditMode = false,
    this.existingItem,
  });

  factory TrackMetadataScreen.edit({
    Key? key,
    required UploadItem item,
  }) {
    return TrackMetadataScreen(
      key: key,
      trackId: item.id,
      fileName: item.title,
      isEditMode: true,
      existingItem: item,
    );
  }

  @override
  ConsumerState<TrackMetadataScreen> createState() => _TrackMetadataScreenState();
}

class _TrackMetadataScreenState extends ConsumerState<TrackMetadataScreen> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _captionController = TextEditingController();
  final _recordLabelController = TextEditingController();
  final _publisherController = TextEditingController();
  final _isrcController = TextEditingController();
  final _pLineController = TextEditingController();
  final _availabilityRegionsController = TextEditingController();

  UploadMetadataTab _selectedTab = UploadMetadataTab.trackInfo;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.isEditMode && widget.existingItem != null) {
        ref.read(trackMetadataProvider.notifier).prepareForEdit(widget.existingItem!);
        ref.read(uploadProvider.notifier).primeTrackForEditing(trackId: widget.trackId);
      } else {
        ref.read(trackMetadataProvider.notifier).prepareForNewUpload(widget.fileName);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _descriptionController.dispose();
    _captionController.dispose();
    _recordLabelController.dispose();
    _publisherController.dispose();
    _isrcController.dispose();
    _pLineController.dispose();
    _availabilityRegionsController.dispose();
    super.dispose();
  }

  void _sync(TextEditingController ctrl, String value) {
    if (ctrl.text == value) return;
    ctrl.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _syncControllers(TrackMetadataState s) {
    _sync(_titleController, s.title);
    _sync(_descriptionController, s.description);
    _sync(_captionController, s.tagsText);
    _sync(_recordLabelController, s.recordLabel);
    _sync(_publisherController, s.publisher);
    _sync(_isrcController, s.isrc);
    _sync(_pLineController, s.pLine);
    _sync(_availabilityRegionsController, s.availabilityRegionsText);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickReleaseDate() async {
    final s = ref.read(trackMetadataProvider);
    final selected = await showDatePicker(
      context: context,
      initialDate: s.scheduledReleaseDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (selected != null) {
      ref.read(trackMetadataProvider.notifier).setScheduledReleaseDate(selected);
    }
  }

  Future<void> _handleSave() async {
    final notifier = ref.read(trackMetadataProvider.notifier);
    final success = widget.isEditMode
        ? await notifier.saveForEdit(widget.trackId)
        : await notifier.saveForNewUpload(widget.trackId);

    if (!success || !mounted) return;

    await ref.read(libraryUploadsProvider.notifier).refresh();
    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  Future<void> _handleDelete() async {
    final item = widget.existingItem;
    if (!widget.isEditMode || item == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Delete track?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${item.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    await ref.read(libraryUploadsProvider.notifier).deleteTrack(item.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Widget _buildStickyHeader(TrackMetadataState s) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFFD0D0D0),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    widget.isEditMode ? 'Edit track' : 'Upload',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => showTrackChecklistSheet(context, s),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      UploadChecklistProgressRing(
                        progress: s.checklistProgress,
                        size: 42,
                        strokeWidth: 3,
                      ),
                      Text(
                        '${s.completedChecklistItems}/4',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TrackMetadataTabSwitcher(
            selectedTab: _selectedTab,
            onTabSelected: (tab) => setState(() => _selectedTab = tab),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    if (!widget.isEditMode) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: GestureDetector(
        onTap: _handleDelete,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1414),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Delete track',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent(
    TrackMetadataState s,
    dynamic uploadState,
    bool uploadFinished,
    String fileName,
  ) {
    late Widget content;

    switch (_selectedTab) {
      case UploadMetadataTab.trackInfo:
        content = Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2E2E2E)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrackFileSummarySection(
                displayedFileName: fileName,
                artworkPath: s.artworkPath,
                uploadFinished: uploadFinished || widget.isEditMode,
                isPreparingUpload: uploadState.isPreparingUpload,
                isUploading: uploadState.isUploading,
                uploadProgress: uploadState.uploadProgress,
                onPickArtwork: () => showArtworkSourceSheet(
                  context,
                  onPickFromGallery: () =>
                      ref.read(trackMetadataProvider.notifier).pickArtwork(),
                  onPickFromCamera: () => ref
                      .read(trackMetadataProvider.notifier)
                      .pickArtwork(fromCamera: true),
                ),
                onReplaceAudio: () =>
                    ref.read(uploadProvider.notifier).replaceCurrentAudioAndStartUpload(),
              ),
              const SizedBox(height: 26),
              TrackInfoFormSection(
                titleController: _titleController,
                artistController: _artistController,
                descriptionController: _descriptionController,
                captionController: _captionController,
                artists: s.artists,
                hasGenre: s.hasGenre,
                selectedGenreLabel: s.selectedGenre.label,
                onTitleChanged: ref.read(trackMetadataProvider.notifier).setTitle,
                onAddArtist: ref.read(trackMetadataProvider.notifier).addArtist,
                onRemoveArtist: ref.read(trackMetadataProvider.notifier).removeArtist,
                onGenreTap: () => showGenrePickerSheet(
                  context,
                  selectedGenre: s.selectedGenre,
                  onGenreSelected: ref.read(trackMetadataProvider.notifier).setGenre,
                ),
                onDescriptionChanged:
                    ref.read(trackMetadataProvider.notifier).setDescription,
                onCaptionChanged: ref.read(trackMetadataProvider.notifier).setTagsText,
              ),
              const SizedBox(height: 28),
              PrivacySection(
                currentValue: s.privacy,
                onChanged: ref.read(trackMetadataProvider.notifier).setPrivacy,
              ),
              _buildDeleteButton(),
            ],
          ),
        );
        break;

      case UploadMetadataTab.advanced:
        content = Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2E2E2E)),
          ),
          child: AdvancedMetadataSection(
            recordLabelController: _recordLabelController,
            publisherController: _publisherController,
            isrcController: _isrcController,
            pLineController: _pLineController,
            hasScheduledRelease: s.hasScheduledRelease,
            scheduledReleaseLabel: _formatDate(s.scheduledReleaseDate),
            contentWarning: s.contentWarning,
            onRecordLabelChanged:
                ref.read(trackMetadataProvider.notifier).setRecordLabel,
            onPublisherChanged:
                ref.read(trackMetadataProvider.notifier).setPublisher,
            onIsrcChanged: ref.read(trackMetadataProvider.notifier).setIsrc,
            onPLineChanged: ref.read(trackMetadataProvider.notifier).setPLine,
            onScheduledReleaseChanged:
                ref.read(trackMetadataProvider.notifier).setHasScheduledRelease,
            onPickReleaseDate: _pickReleaseDate,
            onContentWarningChanged:
                ref.read(trackMetadataProvider.notifier).setContentWarning,
          ),
        );
        break;

      case UploadMetadataTab.permissions:
        content = Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2E2E2E)),
          ),
          child: PermissionsMetadataSection(
            allowDownloads: s.allowDownloads,
            offlineListening: s.offlineListening,
            includeInRss: s.includeInRss,
            displayEmbedCode: s.displayEmbedCode,
            appPlaybackEnabled: s.appPlaybackEnabled,
            availabilityType: s.availabilityType,
            availabilityRegionsController: _availabilityRegionsController,
            licensing: s.licensing,
            onAllowDownloadsChanged:
                ref.read(trackMetadataProvider.notifier).setAllowDownloads,
            onOfflineListeningChanged:
                ref.read(trackMetadataProvider.notifier).setOfflineListening,
            onIncludeInRssChanged:
                ref.read(trackMetadataProvider.notifier).setIncludeInRss,
            onDisplayEmbedCodeChanged:
                ref.read(trackMetadataProvider.notifier).setDisplayEmbedCode,
            onAppPlaybackEnabledChanged:
                ref.read(trackMetadataProvider.notifier).setAppPlaybackEnabled,
            onAvailabilityTypeChanged:
                ref.read(trackMetadataProvider.notifier).setAvailabilityType,
            onAvailabilityRegionsChanged:
                ref.read(trackMetadataProvider.notifier).setAvailabilityRegionsText,
            onLicensingChanged: ref.read(trackMetadataProvider.notifier).setLicensing,
          ),
        );
        break;
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          const UploadPromoBanner(),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(trackMetadataProvider);
    final uploadState = ref.watch(uploadProvider);
    _syncControllers(s);

    final uploadFinished = !uploadState.isPreparingUpload &&
        !uploadState.isUploading &&
        uploadState.uploadProgress >= 1.0;

    final fileName = uploadState.selectedAudio?.name ?? widget.fileName;

    final isSaveBusy = s.isSaving || s.isPolling;
    final saveButtonText = widget.isEditMode
        ? (isSaveBusy ? 'Saving...' : 'Save')
        : (isSaveBusy
            ? (s.isPolling ? 'Processing...' : 'Saving...')
            : (uploadFinished ? 'Save' : 'Uploading...'));

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildStickyHeader(s),
            Expanded(
              child: _buildScrollableContent(
                s,
                uploadState,
                uploadFinished,
                fileName,
              ),
            ),
            SaveMetadataFooter(
              errorMessage: s.error,
              buttonText: saveButtonText,
              onSavePressed: isSaveBusy
                  ? null
                  : (widget.isEditMode || uploadFinished ? _handleSave : null),
            ),
          ],
        ),
      ),
    );
  }
}