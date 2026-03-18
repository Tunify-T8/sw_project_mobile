import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/track_metadata_form_controllers.dart';
import '../../providers/track_metadata_provider.dart';
import '../../providers/track_metadata_state.dart';
import '../../providers/upload_provider.dart';
import '../sheets/artwork_source_sheet.dart';
import '../sheets/genre_picker_sheet.dart';
import 'advanced_metadata_section.dart';
import 'permissions_metadata_section.dart';
import 'privacy_section.dart';
import 'track_file_summary_section.dart';
import 'track_info_form_section.dart';
import 'upload_metadata_tab.dart';
import 'upload_promo_banner.dart';
import 'track_metadata_delete_button.dart';

class TrackMetadataBody extends ConsumerWidget {
  const TrackMetadataBody({
    super.key,
    required this.formControllers,
    required this.state,
    required this.selectedTab,
    required this.displayedFileName,
    required this.uploadFinished,
    required this.isEditMode,
    required this.scheduledReleaseLabel,
    required this.onPickReleaseDate,
    required this.onDelete,
  });

  final TrackMetadataFormControllers formControllers;
  final TrackMetadataState state;
  final UploadMetadataTab selectedTab;
  final String displayedFileName;
  final bool uploadFinished;
  final bool isEditMode;
  final String scheduledReleaseLabel;
  final VoidCallback onPickReleaseDate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataNotifier = ref.read(trackMetadataProvider.notifier);
    final uploadState = ref.watch(uploadProvider);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          const UploadPromoBanner(),
          const SizedBox(height: 16),
          _MetadataCard(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(selectedTab),
                child: switch (selectedTab) {
                  UploadMetadataTab.trackInfo => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TrackFileSummarySection(
                        displayedFileName: displayedFileName,
                        artworkPath: state.artworkPath,
                        uploadFinished: uploadFinished || isEditMode,
                        isPreparingUpload: uploadState.isPreparingUpload,
                        isUploading: uploadState.isUploading,
                        uploadProgress: uploadState.uploadProgress,
                        onPickArtwork: () => showArtworkSourceSheet(
                          context,
                          onPickFromGallery: metadataNotifier.pickArtwork,
                          onPickFromCamera: () =>
                              metadataNotifier.pickArtwork(fromCamera: true),
                        ),
                        onReplaceAudio: ref
                            .read(uploadProvider.notifier)
                            .replaceCurrentAudioAndStartUpload,
                      ),
                      const SizedBox(height: 26),
                      TrackInfoFormSection(
                        titleController: formControllers.title,
                        artistController: formControllers.artist,
                        descriptionController: formControllers.description,
                        captionController: formControllers.caption,
                        artists: state.artists,
                        hasGenre: state.hasGenre,
                        selectedGenreLabel: state.selectedGenre.label,
                        onTitleChanged: metadataNotifier.setTitle,
                        onAddArtist: metadataNotifier.addArtist,
                        onRemoveArtist: metadataNotifier.removeArtist,
                        onGenreTap: () => showGenrePickerSheet(
                          context,
                          selectedGenre: state.selectedGenre,
                          onGenreSelected: metadataNotifier.setGenre,
                        ),
                        onDescriptionChanged: metadataNotifier.setDescription,
                        onCaptionChanged: metadataNotifier.setTagsText,
                      ),
                      const SizedBox(height: 28),
                      PrivacySection(
                        currentValue: state.privacy,
                        onChanged: metadataNotifier.setPrivacy,
                      ),
                      TrackMetadataDeleteButton(
                        visible: isEditMode,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                  UploadMetadataTab.advanced => AdvancedMetadataSection(
                    recordLabelController: formControllers.recordLabel,
                    publisherController: formControllers.publisher,
                    isrcController: formControllers.isrc,
                    pLineController: formControllers.pLine,
                    hasScheduledRelease: state.hasScheduledRelease,
                    scheduledReleaseLabel: scheduledReleaseLabel,
                    contentWarning: state.contentWarning,
                    onRecordLabelChanged: metadataNotifier.setRecordLabel,
                    onPublisherChanged: metadataNotifier.setPublisher,
                    onIsrcChanged: metadataNotifier.setIsrc,
                    onPLineChanged: metadataNotifier.setPLine,
                    onScheduledReleaseChanged:
                        metadataNotifier.setHasScheduledRelease,
                    onPickReleaseDate: onPickReleaseDate,
                    onContentWarningChanged: metadataNotifier.setContentWarning,
                  ),
                  UploadMetadataTab.permissions => PermissionsMetadataSection(
                    allowDownloads: state.allowDownloads,
                    offlineListening: state.offlineListening,
                    includeInRss: state.includeInRss,
                    displayEmbedCode: state.displayEmbedCode,
                    appPlaybackEnabled: state.appPlaybackEnabled,
                    availabilityType: state.availabilityType,
                    availabilityRegionsController:
                        formControllers.availabilityRegions,
                    licensing: state.licensing,
                    onAllowDownloadsChanged: metadataNotifier.setAllowDownloads,
                    onOfflineListeningChanged:
                        metadataNotifier.setOfflineListening,
                    onIncludeInRssChanged: metadataNotifier.setIncludeInRss,
                    onDisplayEmbedCodeChanged:
                        metadataNotifier.setDisplayEmbedCode,
                    onAppPlaybackEnabledChanged:
                        metadataNotifier.setAppPlaybackEnabled,
                    onAvailabilityTypeChanged:
                        metadataNotifier.setAvailabilityType,
                    onAvailabilityRegionsChanged:
                        metadataNotifier.setAvailabilityRegionsText,
                    onLicensingChanged: metadataNotifier.setLicensing,
                  ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: child,
    );
  }
}
