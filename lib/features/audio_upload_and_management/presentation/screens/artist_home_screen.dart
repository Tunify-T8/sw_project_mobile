import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_status.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/upload_dependencies_provider.dart';
import '../providers/upload_provider.dart';
import 'track_metadata_screen.dart';

class ArtistHomeScreen extends ConsumerStatefulWidget {
  const ArtistHomeScreen({super.key});

  @override
  ConsumerState<ArtistHomeScreen> createState() => _ArtistHomeScreenState();
}

class _ArtistHomeScreenState extends ConsumerState<ArtistHomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final userId = ref.read(currentUploadUserIdProvider);
      ref.read(uploadProvider.notifier).loadQuota(userId);
    });
  }

  String _homeUploadStatusLabel() {
    final uploadState = ref.read(uploadProvider);
    final metadataState = ref.read(trackMetadataProvider);

    if (uploadState.isPreparingUpload) {
      return 'Preparing to upload';
    }

    if (uploadState.isUploading) {
      final percent = (uploadState.uploadProgress * 100).toStringAsFixed(0);
      return 'Uploading $percent%';
    }

    if (metadataState.isSaving) {
      return 'Preparing to process';
    }

    if (metadataState.isPolling &&
        metadataState.processingStatus == UploadStatus.processing) {
      return 'Processing track';
    }

    if (metadataState.processingStatus == UploadStatus.finished) {
      return 'Upload complete';
    }

    if (metadataState.processingStatus == UploadStatus.failed) {
      return 'Upload failed';
    }

    return 'Ready to upload';
  }

  Future<void> _startUploadFlow() async {
    final userId = ref.read(currentUploadUserIdProvider);

    final createdTrack = await ref
        .read(uploadProvider.notifier)
        .pickAudioCreateDraftAndStartUpload(userId);

    if (!mounted || createdTrack == null) {
      return;
    }

    final latestUploadState = ref.read(uploadProvider);
    final fileName = latestUploadState.selectedAudio?.name ?? 'Audio file';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackMetadataScreen(
          trackId: createdTrack.trackId,
          fileName: fileName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadProvider);
    final artistName = ref.watch(currentArtistNameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.graphic_eq,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Artist Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: uploadState.isPreparingUpload || uploadState.isUploading
                        ? null
                        : _startUploadFlow,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      artistName,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      _homeUploadStatusLabel(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Get back to it',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: const [
                    _HomePlaceholderCard(title: 'Recent Uploads'),
                    _HomePlaceholderCard(title: 'Draft Tracks'),
                    _HomePlaceholderCard(title: 'Performance'),
                    _HomePlaceholderCard(title: 'Audience'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomePlaceholderCard extends StatelessWidget {
  final String title;

  const _HomePlaceholderCard({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
