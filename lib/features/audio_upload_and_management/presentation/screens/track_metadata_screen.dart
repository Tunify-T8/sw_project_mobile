import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_status.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/upload_dependencies_provider.dart';
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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(trackMetadataProvider.notifier)
          .initializeSuggestedTitle(widget.fileName);
    });
  }

  InputDecoration _inputStyle(String label) {
    return const InputDecoration(
      labelStyle: TextStyle(color: Colors.white70),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      filled: false,
    ).copyWith(labelText: label);
  }

  String _processingLabel({
    required bool isSaving,
    required bool isPolling,
    required UploadStatus status,
  }) {
    if (isSaving) {
      return 'Preparing to process';
    }

    if (isPolling && status == UploadStatus.processing) {
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

  Future<void> _replaceAudio() async {
    final updatedTrack = await ref
        .read(uploadProvider.notifier)
        .replaceCurrentAudio();

    if (!mounted || updatedTrack == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio file replaced successfully')),
    );
  }

  Widget _buildTopTabs() {
    Widget tabItem({required String label, required bool selected}) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2B2B2B) : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            border: selected
                ? Border.all(color: Colors.white54)
                : Border.all(color: Colors.transparent),
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
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white24),
        color: Colors.black,
      ),
      child: Row(
        children: [
          tabItem(label: 'Track Info', selected: true),
          tabItem(label: 'Advanced', selected: false),
          tabItem(label: 'Permissions', selected: false),
        ],
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
          border: Border.all(color: Colors.white38, width: 1.2),
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

  Widget _buildUploadIndicator({
    required bool isUploading,
    required double progress,
  }) {
    final uploadFinished = !isUploading && progress >= 1.0;

    if (uploadFinished) {
      return Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFF23C16B),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.black, size: 24),
      );
    }

    return SizedBox(
      width: 42,
      height: 42,
      child: CircularProgressIndicator(
        value: progress == 0.0 ? null : progress,
        color: Colors.white,
        backgroundColor: Colors.white12,
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
        padding: const EdgeInsets.symmetric(vertical: 10),
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70, width: 1.4),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 18, color: Colors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metadataState = ref.watch(trackMetadataProvider);
    final uploadState = ref.watch(uploadProvider);
    final artistName = ref.watch(currentArtistNameProvider);

    final displayedFileName =
        uploadState.selectedAudio?.name ?? widget.fileName;
    final uploadFinished =
        !uploadState.isUploading && uploadState.uploadProgress >= 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Upload',
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTopTabs(),
          const SizedBox(height: 20),
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
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (uploadFinished)
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            onPressed: uploadState.isUploading
                                ? null
                                : _replaceAudio,
                            child: const Text('Replace'),
                          )
                        else
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: uploadState.uploadProgress == 0.0
                                      ? null
                                      : uploadState.uploadProgress,
                                  minHeight: 6,
                                  backgroundColor: Colors.white12,
                                  color: const Color(0xFFFF5500),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  uploadState.isUploading
                                      ? 'Uploading ${(uploadState.uploadProgress * 100).toStringAsFixed(0)}%'
                                      : 'Preparing to upload',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 12),
                        _buildUploadIndicator(
                          isUploading: uploadState.isUploading,
                          progress: uploadState.uploadProgress,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          TextFormField(
            initialValue: metadataState.title,
            style: const TextStyle(color: Colors.white),
            decoration: _inputStyle('Title *'),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setTitle(value);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Artists *',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  artistName,
                  style: const TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your profile name is used as the primary artist.',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: metadataState.genreSubGenre,
            style: const TextStyle(color: Colors.white),
            decoration: _inputStyle('Genre'),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setGenreSubGenre(value);
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: metadataState.description,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: _inputStyle('Description'),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setDescription(value);
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: metadataState.tagsText,
            style: const TextStyle(color: Colors.white),
            decoration: _inputStyle('Tags (comma separated)'),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setTagsText(value);
            },
          ),
          const SizedBox(height: 28),
          const Text(
            'Privacy',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 16),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed:
                  metadataState.isSaving ||
                      metadataState.isPolling ||
                      uploadState.isUploading
                  ? null
                  : () async {
                      final success = await ref
                          .read(trackMetadataProvider.notifier)
                          .saveMetadataAndWait(widget.trackId);

                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Track is fully processed and ready'),
                          ),
                        );
                      }
                    },
              child: metadataState.isSaving || metadataState.isPolling
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Status: ${_processingLabel(isSaving: metadataState.isSaving, isPolling: metadataState.isPolling, status: metadataState.processingStatus)}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          const Text(
            "By uploading, you confirm that your sounds comply with our Terms of Use and you don't infringe anyone else's rights.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'TERMS OF USE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          if (metadataState.finalTrack != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Processed Track Output',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Audio URL: ${metadataState.finalTrack!.audioUrl ?? '-'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waveform URL: ${metadataState.finalTrack!.waveformUrl ?? '-'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Artwork URL: ${metadataState.finalTrack!.artworkUrl ?? '-'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
