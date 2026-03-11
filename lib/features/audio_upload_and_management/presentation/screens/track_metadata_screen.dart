import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/track_metadata_provider.dart';

class TrackMetadataScreen extends ConsumerWidget {
  final String trackId;
  final String fileName;

  const TrackMetadataScreen({
    super.key,
    required this.trackId,
    required this.fileName,
  });

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataState = ref.watch(trackMetadataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Track Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              fileName,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('Title'),
              onChanged: (value) {
                ref.read(trackMetadataProvider.notifier).setTitle(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('Genre'),
              onChanged: (value) {
                ref.read(trackMetadataProvider.notifier).setGenre(value);
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
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('Tags'),
              onChanged: (value) {
                ref.read(trackMetadataProvider.notifier).setTags(value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: metadataState.privacy,
              dropdownColor: const Color(0xFF1C1C1C),
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('Privacy'),
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
            const SizedBox(height: 24),
            if (metadataState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  metadataState.error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5500),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: metadataState.isSaving
                    ? null
                    : () async {
                        final success = await ref
                            .read(trackMetadataProvider.notifier)
                            .saveMetadata(trackId, ref);

                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Track metadata saved'),
                            ),
                          );
                        }
                      },
                child: metadataState.isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Track'),
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
              child: const Text(
                'Waveform will be generated after processing/upload is complete.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}