import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_status.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/track_metadata_state.dart';
import '../providers/upload_provider.dart';

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
    _artistController.dispose();
    super.dispose();
  }

  int _completionCount(TrackMetadataState state) {
    int count = 0;

    if (state.title.trim().isNotEmpty) count++;
    if (state.artworkPath != null && state.artworkPath!.isNotEmpty) count++;
    if (state.genreSubGenre.trim().isNotEmpty) count++;
    if (state.description.trim().isNotEmpty) count++;

    return count;
  }

  void _showChecklistBottomSheet(TrackMetadataState state) {
    final completed = _completionCount(state);

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
            color: done ? Colors.white : Colors.white70,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tip,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 92,
                      height: 92,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: completed / 4,
                            strokeWidth: 8,
                            backgroundColor: Colors.white12,
                            color: const Color(0xFFA855F7),
                          ),
                          Center(
                            child: Text(
                              '$completed/4',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
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
                            done: state.title.trim().isNotEmpty,
                          ),
                          const SizedBox(height: 16),
                          checklistItem(
                            label: 'Artwork',
                            tip: 'Add cover art for better presentation',
                            done: state.artworkPath != null &&
                                state.artworkPath!.isNotEmpty,
                          ),
                          const SizedBox(height: 16),
                          checklistItem(
                            label: 'Genre',
                            tip: 'Help fans discover your track',
                            done: state.genreSubGenre.trim().isNotEmpty,
                          ),
                          const SizedBox(height: 16),
                          checklistItem(
                            label: 'Description',
                            tip: 'Tell listeners more about the track',
                            done: state.description.trim().isNotEmpty,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
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
                child: Image.file(
                  File(artworkPath),
                  fit: BoxFit.cover,
                ),
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
                  const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
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
                  ? const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 18,
                    )
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

  @override
  Widget build(BuildContext context) {
    final metadataState = ref.watch(trackMetadataProvider);
    final uploadState = ref.watch(uploadProvider);

    final uploadFinished =
        !uploadState.isPreparingUpload &&
        !uploadState.isUploading &&
        uploadState.uploadProgress >= 1.0;

    final displayedFileName = uploadState.selectedAudio?.name ?? widget.fileName;
    final completionCount = _completionCount(metadataState);

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
        title: const Text(
          'Upload',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => _showChecklistBottomSheet(metadataState),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38),
                ),
                child: Center(
                  child: Text(
                    '$completionCount/4',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: Colors.white54),
                    ),
                    child: const Text(
                      'Track Info',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Advanced',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Permissions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
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
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayedFileName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
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
                            child: const Icon(
                              Icons.check,
                              color: Colors.black,
                            ),
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
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  controller: TextEditingController(text: metadataState.title)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: metadataState.title.length),
                    ),
                  decoration: _underlineFieldStyle('Title *'),
                  onChanged: (value) {
                    ref.read(trackMetadataProvider.notifier).setTitle(value);
                  },
                ),
                const SizedBox(height: 22),
                const Text(
                  'Artists *',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
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
                  decoration: _underlineFieldStyle(
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
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  controller:
                      TextEditingController(text: metadataState.genreSubGenre)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(
                            offset: metadataState.genreSubGenre.length,
                          ),
                        ),
                  decoration: _underlineFieldStyle(
                    'Genre',
                    hintText: 'Help fans discover your track',
                  ),
                  onChanged: (value) {
                    ref
                        .read(trackMetadataProvider.notifier)
                        .setGenreSubGenre(value);
                  },
                ),
                const SizedBox(height: 22),
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  controller:
                      TextEditingController(text: metadataState.description)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(
                            offset: metadataState.description.length,
                          ),
                        ),
                  maxLines: 3,
                  decoration: _underlineFieldStyle(
                    'Description',
                    hintText: 'Add any details about your track for fans',
                  ),
                  onChanged: (value) {
                    ref.read(trackMetadataProvider.notifier).setDescription(value);
                  },
                ),
                const SizedBox(height: 22),
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  controller: TextEditingController(text: metadataState.tagsText)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: metadataState.tagsText.length),
                    ),
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
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
          const SizedBox(height: 12),
          if (metadataState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                metadataState.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          SizedBox(
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
              onPressed: uploadFinished &&
                      !metadataState.isSaving &&
                      !metadataState.isPolling
                  ? () {
                      ref
                          .read(trackMetadataProvider.notifier)
                          .saveMetadataAndProcessInBackground(widget.trackId);

                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  : null,
              child: Text(
                uploadFinished ? 'Save' : 'Uploading...',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
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
