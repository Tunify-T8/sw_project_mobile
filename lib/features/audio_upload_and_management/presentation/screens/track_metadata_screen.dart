import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_status.dart';
import '../providers/track_metadata_provider.dart';

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
  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFFF5500)),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: const Color(0xFF1C1C1C),
    );
  }

  String _processingLabel(UploadStatus status) {
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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(trackMetadataProvider.notifier)
          .initializeSuggestedTitle(widget.fileName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final metadataState = ref.watch(trackMetadataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Track details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.fileName,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputStyle('Title'),
            controller: TextEditingController(text: metadataState.title)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: metadataState.title.length),
              ),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setTitle(value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputStyle('Genre category'),
            controller: TextEditingController(text: metadataState.genreCategory)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: metadataState.genreCategory.length),
              ),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setGenreCategory(value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputStyle('Sub-genre'),
            controller: TextEditingController(text: metadataState.genreSubGenre)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: metadataState.genreSubGenre.length),
              ),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setGenreSubGenre(value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputStyle('Tags (comma separated)'),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setTagsText(value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: _inputStyle('Description'),
            onChanged: (value) {
              ref.read(trackMetadataProvider.notifier).setDescription(value);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: metadataState.privacy,
            dropdownColor: const Color(0xFF1C1C1C),
            decoration: _inputStyle('Privacy'),
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'public', child: Text('Public')),
              DropdownMenuItem(value: 'private', child: Text('Private')),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(trackMetadataProvider.notifier).setPrivacy(value);
              }
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
            ),
            onPressed: () {
              ref.read(trackMetadataProvider.notifier).pickArtwork();
            },
            child: Text(
              metadataState.artworkPath == null
                  ? 'Choose artwork image'
                  : 'Artwork selected',
            ),
          ),
          const SizedBox(height: 16),
          if (metadataState.error != null)
            Text(
              metadataState.error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5500),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: metadataState.isSaving || metadataState.isPolling
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
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save and process'),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Processing status: ${_processingLabel(metadataState.processingStatus)}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Waveform is usually produced by backend processing after upload, so here we wait for the final processed response instead of generating it inside Flutter.',
                  style: TextStyle(color: Colors.white70),
                ),
                if (metadataState.finalTrack != null) ...[
                  const SizedBox(height: 12),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}