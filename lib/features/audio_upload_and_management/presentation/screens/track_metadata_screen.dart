import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      ref
          .read(trackMetadataProvider.notifier)
          .prepareForNewUpload(widget.fileName);
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

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;

    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _syncControllers(TrackMetadataState state) {
    _sync(_titleController, state.title);
    _sync(_descriptionController, state.description);
    _sync(_captionController, state.tagsText);
    _sync(_recordLabelController, state.recordLabel);
    _sync(_publisherController, state.publisher);
    _sync(_isrcController, state.isrc);
    _sync(_pLineController, state.pLine);
    _sync(_availabilityRegionsController, state.availabilityRegionsText);
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

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
    final month = months[date.month - 1];
    return '$day $month ${date.year}';
  }

  Future<void> _pickReleaseDate() async {
    final metadataState = ref.read(trackMetadataProvider);

    final selected = await showDatePicker(
      context: context,
      initialDate: metadataState.scheduledReleaseDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );

    if (selected != null) {
      ref
          .read(trackMetadataProvider.notifier)
          .setScheduledReleaseDate(selected);
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

  Widget _buildStickyHeader(TrackMetadataState metadataState) {
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
              const Expanded(
                child: Center(
                  child: Text(
                    'Upload',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => showTrackChecklistSheet(context, metadataState),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      UploadChecklistProgressRing(
                        progress: metadataState.checklistProgress,
                        size: 42,
                        strokeWidth: 3,
                      ),
                      Text(
                        '${metadataState.completedChecklistItems}/4',
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

  Widget _buildTrackInfoCard(
    TrackMetadataState metadataState,
    dynamic uploadState,
    bool uploadFinished,
    String displayedFileName,
  ) {
    return Container(
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
          const SizedBox(height: 26),
          TrackInfoFormSection(
            titleController: _titleController,
            artistController: _artistController,
            descriptionController: _descriptionController,
            captionController: _captionController,
            artists: metadataState.artists,
            hasGenre: metadataState.hasGenre,
            selectedGenreLabel: metadataState.selectedGenre.label,
            onTitleChanged: ref.read(trackMetadataProvider.notifier).setTitle,
            onAddArtist: ref.read(trackMetadataProvider.notifier).addArtist,
            onRemoveArtist: ref
                .read(trackMetadataProvider.notifier)
                .removeArtist,
            onGenreTap: () {
              showGenrePickerSheet(
                context,
                selectedGenre: metadataState.selectedGenre,
                onGenreSelected: ref
                    .read(trackMetadataProvider.notifier)
                    .setGenre,
              );
            },
            onDescriptionChanged: ref
                .read(trackMetadataProvider.notifier)
                .setDescription,
            onCaptionChanged: ref
                .read(trackMetadataProvider.notifier)
                .setTagsText,
          ),
          const SizedBox(height: 28),
          PrivacySection(
            currentValue: metadataState.privacy,
            onChanged: ref.read(trackMetadataProvider.notifier).setPrivacy,
          ),
        ],
      ),
    );
  }

Widget _buildAdvancedContent(TrackMetadataState metadataState) {
  return Container(
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
      hasScheduledRelease: metadataState.hasScheduledRelease,
      scheduledReleaseLabel: _formatDate(metadataState.scheduledReleaseDate),
      contentWarning: metadataState.contentWarning,
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
}

  Widget _buildPermissionsCard(TrackMetadataState metadataState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: PermissionsMetadataSection(
        allowDownloads: metadataState.allowDownloads,
        offlineListening: metadataState.offlineListening,
        includeInRss: metadataState.includeInRss,
        displayEmbedCode: metadataState.displayEmbedCode,
        appPlaybackEnabled: metadataState.appPlaybackEnabled,
        availabilityType: metadataState.availabilityType,
        availabilityRegionsController: _availabilityRegionsController,
        licensing: metadataState.licensing,
        onAllowDownloadsChanged: ref
            .read(trackMetadataProvider.notifier)
            .setAllowDownloads,
        onOfflineListeningChanged: ref
            .read(trackMetadataProvider.notifier)
            .setOfflineListening,
        onIncludeInRssChanged: ref
            .read(trackMetadataProvider.notifier)
            .setIncludeInRss,
        onDisplayEmbedCodeChanged: ref
            .read(trackMetadataProvider.notifier)
            .setDisplayEmbedCode,
        onAppPlaybackEnabledChanged: ref
            .read(trackMetadataProvider.notifier)
            .setAppPlaybackEnabled,
        onAvailabilityTypeChanged: ref
            .read(trackMetadataProvider.notifier)
            .setAvailabilityType,
        onAvailabilityRegionsChanged: ref
            .read(trackMetadataProvider.notifier)
            .setAvailabilityRegionsText,
        onLicensingChanged: ref
            .read(trackMetadataProvider.notifier)
            .setLicensing,
      ),
    );
  }

Widget _buildScrollableContent(
  TrackMetadataState metadataState,
  dynamic uploadState,
  bool uploadFinished,
  String displayedFileName,
) {
  late final Widget content;

  switch (_selectedTab) {
    case UploadMetadataTab.trackInfo:
      content = _buildTrackInfoCard(
        metadataState,
        uploadState,
        uploadFinished,
        displayedFileName,
      );
      break;
    case UploadMetadataTab.advanced:
      content = _buildAdvancedContent(metadataState);
      break;
    case UploadMetadataTab.permissions:
      content = _buildPermissionsCard(metadataState);
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
    final metadataState = ref.watch(trackMetadataProvider);
    final uploadState = ref.watch(uploadProvider);

    _syncControllers(metadataState);

    final uploadFinished =
        !uploadState.isPreparingUpload &&
        !uploadState.isUploading &&
        uploadState.uploadProgress >= 1.0;

    final displayedFileName =
        uploadState.selectedAudio?.name ?? widget.fileName;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildStickyHeader(metadataState),
            Expanded(
              child: _buildScrollableContent(
                metadataState,
                uploadState,
                uploadFinished,
                displayedFileName,
              ),
            ),
            SaveMetadataFooter(
              errorMessage: metadataState.error,
              buttonText: uploadFinished ? 'Save' : 'Uploading...',
              onSavePressed:
                  uploadFinished &&
                      !metadataState.isSaving &&
                      !metadataState.isPolling
                  ? _handleSave
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}