import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_status.dart';
import '../providers/upload_provider.dart';
import 'track_metadata_screen.dart';

class UploadEntryScreen extends ConsumerStatefulWidget {
  const UploadEntryScreen({super.key});

  @override
  ConsumerState<UploadEntryScreen> createState() => _UploadEntryScreenState();
}

class _UploadEntryScreenState extends ConsumerState<UploadEntryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(uploadProvider.notifier).loadQuota();
    });
  }

  String _statusText(UploadStatus status) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Upload',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (uploadState.isLoadingQuota)
              const Center(child: CircularProgressIndicator())
            else
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
                      'Plan: ${uploadState.tier}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Remaining upload minutes: ${uploadState.uploadMinutesRemaining}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
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
                  const Text(
                    'Selected file',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    uploadState.selectedFileName ?? 'No audio file selected',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      ref.read(uploadProvider.notifier).pickFile();
                    },
                    child: const Text('Choose Audio File'),
                  ),
                ],
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
                    'Track ID: ${uploadState.trackId ?? "-"}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${_statusText(uploadState.status)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: uploadState.progress,
                    backgroundColor: Colors.white12,
                    color: const Color(0xFFFF5500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progress: ${(uploadState.progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            if (uploadState.error != null) ...[
              const SizedBox(height: 16),
              Text(
                uploadState.error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 24),
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
                onPressed: () async {
                  final success = await ref
                      .read(uploadProvider.notifier)
                      .createAndUploadTrack();

                  if (success &&
                      context.mounted &&
                      uploadState.selectedFileName != null &&
                      ref.read(uploadProvider).trackId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackMetadataScreen(
                          trackId: ref.read(uploadProvider).trackId!,
                          fileName: ref.read(uploadProvider).selectedFileName!,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Upload Track'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}