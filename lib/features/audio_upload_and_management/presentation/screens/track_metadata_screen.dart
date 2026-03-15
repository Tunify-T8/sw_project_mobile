import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_genre.dart';
import '../../domain/entities/upload_status.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/track_metadata_state.dart';
import '../providers/upload_provider.dart';
import '../widgets/upload_checklist_progress_ring.dart';

enum _UploadTab { trackInfo, advanced, permissions }

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
  final TextEditingController _artistController = TextEditingController();
  _UploadTab _selectedTab = _UploadTab.trackInfo;

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
    _artistController.dispose();
    super.dispose();
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
    final year = date.year.toString();

    return '$day $month $year';
  }

  Future<void> _pickReleaseDate() async {
    final metadataState = ref.read(trackMetadataProvider);

    final selected = await showDatePicker(
      context: context,
      initialDate: metadataState.scheduledReleaseDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );

    if (selected != null) {
      ref
          .read(trackMetadataProvider.notifier)
          .setScheduledReleaseDate(selected);
    }
  }

  void _showChecklistBottomSheet(TrackMetadataState state) {
    final completed = state.completedChecklistItems;

    Widget checklistItem({
      required String label,
      required String tip,
      required bool done,
    }) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? const Color(0xFFA855F7) : Colors.white70,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
                const SizedBox(height: 2),
                Text(
                  tip,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      );
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF242424),
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.74,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Get everything in place',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Fans are more likely to play your track when you complete these:',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 92,
                            height: 92,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                UploadChecklistProgressRing(
                                  progress: state.checklistProgress,
                                  size: 92,
                                  strokeWidth: 8,
                                ),
                                Text(
                                  '$completed/4',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                checklistItem(
                                  label: 'Title',
                                  tip: "Tip: don't include artist name",
                                  done: state.hasTitle,
                                ),
                                const SizedBox(height: 16),
                                checklistItem(
                                  label: 'Artwork',
                                  tip: 'Add cover art for better presentation',
                                  done: state.hasArtwork,
                                ),
                                const SizedBox(height: 16),
                                checklistItem(
                                  label: 'Genre',
                                  tip: 'Help fans discover your track',
                                  done: state.hasGenre,
                                ),
                                const SizedBox(height: 16),
                                checklistItem(
                                  label: 'Description',
                                  tip:
                                      'Add any details about your track for fans',
                                  done: state.hasDescription,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Ok, got it',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showArtworkSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Choose from gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(trackMetadataProvider.notifier).pickArtwork();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Take photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(trackMetadataProvider.notifier)
                      .pickArtwork(fromCamera: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showGenreBottomSheet(TrackMetadataState state) async {
    final selectedGenre = state.selectedGenre;

    Widget buildSectionLabel(String label) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    Widget buildGenreTile(UploadGenre genre) {
      final isSelected = genre.isNone
          ? selectedGenre.isNone
          : selectedGenre.categoryValue == genre.categoryValue &&
                selectedGenre.subGenre == genre.subGenre;

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        title: Text(
          genre.label,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: Colors.white)
            : null,
        onTap: () {
          ref.read(trackMetadataProvider.notifier).setGenre(genre);
          Navigator.pop(context);
        },
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.82,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    children: [
                      buildGenreTile(UploadGenres.none),
                      buildSectionLabel('Music'),
                      ...UploadGenres.music.map(buildGenreTile),
                      buildSectionLabel('Audio'),
                      ...UploadGenres.audio.map(buildGenreTile),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _underlineFieldStyle(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white70),
      ),
    );
  }

  Widget _buildArtworkTile(String? artworkPath) {
    return GestureDetector(
      onTap: _showArtworkSourceSheet,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white54,
            width: 1.2,
            style: BorderStyle.solid,
          ),
        ),
        child: artworkPath == null || artworkPath.isEmpty
            ? const Center(
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(artworkPath), fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildProgressPill({
    required bool isPreparingUpload,
    required bool isUploading,
    required double progress,
  }) {
    String label;

    if (isPreparingUpload) {
      label = 'PREPARING TO UPLOAD';
    } else if (isUploading) {
      label = 'UPLOADING ${(progress * 100).toStringAsFixed(0)}%';
    } else {
      label = 'UPLOADING 100%';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF0C5F3B),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: isPreparingUpload ? 0.15 : progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF11A85B),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Icon(Icons.close, color: Colors.white70, size: 20),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOption({
    required String value,
    required String currentValue,
    required String title,
    required String subtitle,
  }) {
    final isSelected = value == currentValue;

    return InkWell(
      onTap: () {
        ref.read(trackMetadataProvider.notifier).setPrivacy(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70, width: 1.5),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF4CD08D),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioRow({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70, width: 1.5),
                color: selected ? Colors.white : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.black, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _processingText(TrackMetadataState state) {
    if (state.isSaving) {
      return 'Preparing to process';
    }

    if (state.isPolling) {
      return 'Processing';
    }

    switch (state.processingStatus) {
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

  Widget _buildGenreField(TrackMetadataState metadataState) {
    final selectedGenre = metadataState.selectedGenre;
    final hasGenre = metadataState.hasGenre;

    return InkWell(
      onTap: () => _showGenreBottomSheet(metadataState),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Genre',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasGenre
                      ? selectedGenre.label
                      : 'Help fans discover your track',
                  style: TextStyle(
                    color: hasGenre ? Colors.white : Colors.white38,
                    fontSize: 18,
                  ),
                ),
              ),
              const Icon(Icons.unfold_more, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    Widget tabButton({required _UploadTab tab, required String label}) {
      final selected = _selectedTab == tab;

      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedTab = tab;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF2B2B2B) : Colors.transparent,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: selected ? Colors.white54 : Colors.transparent,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          tabButton(tab: _UploadTab.trackInfo, label: 'Track Info'),
          tabButton(tab: _UploadTab.advanced, label: 'Advanced'),
          tabButton(tab: _UploadTab.permissions, label: 'Permissions'),
        ],
      ),
    );
  }

  Widget _buildTrackInfoTab(
    TrackMetadataState metadataState,
    bool uploadFinished,
    String displayedFileName,
    dynamic uploadState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArtworkTile(metadataState.artworkPath),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filename',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayedFileName,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 14),
                  if (!uploadFinished)
                    _buildProgressPill(
                      isPreparingUpload: uploadState.isPreparingUpload,
                      isUploading: uploadState.isUploading,
                      progress: uploadState.uploadProgress,
                    )
                  else
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            ref
                                .read(uploadProvider.notifier)
                                .replaceCurrentAudioAndStartUpload();
                          },
                          child: const Text('Replace'),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFF37B26C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.black),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: metadataState.title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: _underlineFieldStyle('Title *'),
                onChanged: (value) {
                  ref.read(trackMetadataProvider.notifier).setTitle(value);
                },
              ),
              const SizedBox(height: 22),
              const Text(
                'Artists *',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: metadataState.artists.map((artist) {
                  final canRemove = metadataState.artists.length > 1;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          artist.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: canRemove
                              ? () {
                                  ref
                                      .read(trackMetadataProvider.notifier)
                                      .removeArtist(artist);
                                }
                              : null,
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: canRemove ? Colors.white70 : Colors.white24,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _artistController,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _underlineFieldStyle(
                      '',
                      hintText: 'Add any other collaborators of the track',
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () {
                          ref
                              .read(trackMetadataProvider.notifier)
                              .addArtist(_artistController.text);
                          _artistController.clear();
                        },
                        icon: const Icon(Icons.add, color: Colors.white70),
                      ),
                    ),
                onSubmitted: (value) {
                  ref.read(trackMetadataProvider.notifier).addArtist(value);
                  _artistController.clear();
                },
              ),
              const SizedBox(height: 22),
              _buildGenreField(metadataState),
              const SizedBox(height: 22),
              TextFormField(
                initialValue: metadataState.description,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                maxLines: 3,
                decoration: _underlineFieldStyle(
                  'Description',
                  hintText: 'Add any details about your track for fans',
                ),
                onChanged: (value) {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setDescription(value);
                },
              ),
              const SizedBox(height: 22),
              TextFormField(
                initialValue: metadataState.tagsText,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: _underlineFieldStyle(
                  'Tags',
                  hintText: 'Add comma separated tags',
                ),
                onChanged: (value) {
                  ref.read(trackMetadataProvider.notifier).setTagsText(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Privacy',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        _buildPrivacyOption(
          value: 'public',
          currentValue: metadataState.privacy,
          title: 'Public',
          subtitle: 'Anyone can find this',
        ),
        _buildPrivacyOption(
          value: 'private',
          currentValue: metadataState.privacy,
          title: 'Unlisted (Private)',
          subtitle: 'Anyone with private link can access',
        ),
      ],
    );
  }

  Widget _buildAdvancedTab(TrackMetadataState metadataState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: metadataState.recordLabel,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: _underlineFieldStyle(
              'Record label',
              hintText: 'Add your record label if applicable',
            ),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setRecordLabel(value);
            },
          ),
          const SizedBox(height: 26),
          const Text(
            'Release date',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: metadataState.hasScheduledRelease
                      ? _pickReleaseDate
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _formatDate(metadataState.scheduledReleaseDate),
                      style: TextStyle(
                        color: metadataState.hasScheduledRelease
                            ? Colors.white
                            : Colors.white38,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: metadataState.hasScheduledRelease,
                onChanged: (value) {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setHasScheduledRelease(value);
                },
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF4CD08D),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white24,
              ),
            ],
          ),
          const SizedBox(height: 26),
          TextFormField(
            initialValue: metadataState.publisher,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: _underlineFieldStyle(
              'Publisher',
              hintText: 'Add your publisher if you have one',
            ),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setPublisher(value);
            },
          ),
          const SizedBox(height: 26),
          TextFormField(
            initialValue: metadataState.isrc,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: _underlineFieldStyle(
              'ISRC',
              hintText: 'e.g. USABC2312345',
            ),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setIsrc(value);
            },
          ),
          const SizedBox(height: 28),
          _buildToggleRow(
            title: 'Content warning',
            subtitle: 'Contains explicit content',
            value: metadataState.contentWarning,
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setContentWarning(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab(TrackMetadataState metadataState) {
    final showRegionsField = metadataState.availabilityType != 'worldwide';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Access Settings',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 10),
              _buildToggleRow(
                title: 'Enable direct downloads',
                subtitle:
                    'Allow listeners to download the original audio file.',
                value: metadataState.allowDownloads,
                onChanged: (value) {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setAllowDownloads(value);
                },
              ),
              _buildToggleRow(
                title: 'Offline listening',
                subtitle:
                    'Offline listening allows this track to be played on devices without an internet connection.',
                value: metadataState.offlineListening,
                onChanged: (value) {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setOfflineListening(value);
                },
              ),
              _buildToggleRow(
                title: 'Include in RSS feed',
                subtitle:
                    'Choose whether you want this track to show up in your public RSS feed.',
                value: metadataState.includeInRss,
                onChanged: (value) {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setIncludeInRss(value);
                },
              ),
              _buildToggleRow(
                title: 'Display embed code',
                subtitle:
                    "Choose whether you want this track's embedded-player code to be displayed publicly.",
                value: metadataState.displayEmbedCode,
                onChanged: (value) {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setDisplayEmbedCode(value);
                },
              ),
              _buildToggleRow(
                title: 'Enable app playback',
                subtitle:
                    'Choose whether you want this track to be playable outside the app shell.',
                value: metadataState.appPlaybackEnabled,
                onChanged: (value) {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setAppPlaybackEnabled(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Availability',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 10),
              _buildRadioRow(
                title: 'Worldwide',
                subtitle: 'Track is available in all regions.',
                selected: metadataState.availabilityType == 'worldwide',
                onTap: () {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setAvailabilityType('worldwide');
                },
              ),
              _buildRadioRow(
                title: 'Exclusive regions',
                subtitle: 'Only selected regions can access this track.',
                selected: metadataState.availabilityType == 'exclusive_regions',
                onTap: () {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setAvailabilityType('exclusive_regions');
                },
              ),
              _buildRadioRow(
                title: 'Blocked regions',
                subtitle:
                    'Selected regions are blocked while the rest remain available.',
                selected: metadataState.availabilityType == 'excluded_regions',
                onTap: () {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setAvailabilityType('excluded_regions');
                },
              ),
              if (showRegionsField) ...[
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: metadataState.availabilityRegionsText,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _underlineFieldStyle(
                    'Regions',
                    hintText: 'Comma separated ISO codes, e.g. EG, US, DE',
                  ),
                  onChanged: (value) {
                    ref
                        .read(trackMetadataProvider.notifier)
                        .setAvailabilityRegionsText(value);
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Licensing',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 10),
              _buildRadioRow(
                title: 'All rights reserved',
                subtitle:
                    'Other creators are not allowed to reuse your material.',
                selected: metadataState.licensing == 'all_rights_reserved',
                onTap: () {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setLicensing('all_rights_reserved');
                },
              ),
              _buildRadioRow(
                title: 'Creative Commons',
                subtitle:
                    'Allow limited reuse under a Creative Commons license.',
                selected: metadataState.licensing == 'creative_commons',
                onTap: () {
                  ref
                      .read(trackMetadataProvider.notifier)
                      .setLicensing('creative_commons');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton({
    required bool uploadFinished,
    required TrackMetadataState metadataState,
  }) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: const Color(0xFFBDBDBD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed:
            uploadFinished &&
                !metadataState.isSaving &&
                !metadataState.isPolling
            ? () async {
                final started = await ref
                    .read(trackMetadataProvider.notifier)
                    .saveMetadataAndProcessInBackground(widget.trackId);

                if (!started || !mounted) {
                  return;
                }

                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            : null,
        child: Text(
          uploadFinished ? 'Save' : 'Uploading...',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metadataState = ref.watch(trackMetadataProvider);
    final uploadState = ref.watch(uploadProvider);

    final uploadFinished =
        !uploadState.isPreparingUpload &&
        !uploadState.isUploading &&
        uploadState.uploadProgress >= 1.0;

    final displayedFileName =
        uploadState.selectedAudio?.name ?? widget.fileName;
    final completionCount = metadataState.completedChecklistItems;

    Widget selectedContent;

    switch (_selectedTab) {
      case _UploadTab.trackInfo:
        selectedContent = _buildTrackInfoTab(
          metadataState,
          uploadFinished,
          displayedFileName,
          uploadState,
        );
        break;
      case _UploadTab.advanced:
        selectedContent = _buildAdvancedTab(metadataState);
        break;
      case _UploadTab.permissions:
        selectedContent = _buildPermissionsTab(metadataState);
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        leadingWidth: 90,
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
        centerTitle: true,
        title: const Text('Upload', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => _showChecklistBottomSheet(metadataState),
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
                      '$completionCount/4',
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
          _buildTabBar(),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF7C3AED),
                  child: Icon(Icons.flash_on, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Amplify your track with Artist Pro',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          selectedContent,
          const SizedBox(height: 12),
          if (metadataState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                metadataState.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          _buildSaveButton(
            uploadFinished: uploadFinished,
            metadataState: metadataState,
          ),
          const SizedBox(height: 14),
          Text(
            'Status: ${_processingText(metadataState)}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          const Text(
            "By uploading, you confirm that your sounds comply with our Terms of Use and you don't infringe anyone else's rights.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 10),
          const Text(
            'TERMS OF USE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
