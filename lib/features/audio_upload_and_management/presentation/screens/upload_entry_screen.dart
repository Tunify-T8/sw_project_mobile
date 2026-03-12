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
  static const String demoUserId = 'user-demo-id';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(uploadProvider.notifier).loadQuota(demoUserId);
    });
  }

  String _statusLabel(UploadStatus? status) {
    if (status == null) return '-';

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: uploadState.isLoadingQuota
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload quota',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tier: ${uploadState.quota?.tier ?? '-'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Remaining minutes: ${uploadState.quota?.uploadMinutesRemaining ?? '-'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
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
                  'Audio file',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  uploadState.selectedAudio?.name ?? 'No file selected',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  onPressed: () {
                    ref.read(uploadProvider.notifier).pickAudioFile();
                  },
                  child: const Text('Choose audio file'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (uploadState.currentTrack != null ||
              uploadState.uploadProgress > 0.0) ...[
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
                    'Track ID: ${uploadState.currentTrack?.trackId ?? '-'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${_statusLabel(uploadState.currentTrack?.status)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: uploadState.uploadProgress,
                    color: const Color(0xFFFF5500),
                    backgroundColor: Colors.white12,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload progress: ${(uploadState.uploadProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (uploadState.error != null)
            Text(
              uploadState.error!,
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
              onPressed: uploadState.isUploading
                  ? null
                  : () async {
                      final track = await ref
                          .read(uploadProvider.notifier)
                          .createTrackAndUpload(demoUserId);

                      if (track != null &&
                          context.mounted &&
                          uploadState.selectedAudio != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrackMetadataScreen(
                              trackId: track.trackId,
                              fileName: ref.read(uploadProvider).selectedAudio!.name,
                            ),
                          ),
                        );
                      }
                    },
              child: uploadState.isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload track'),
            ),
          ),
        ],
      ),
    );
  }
}