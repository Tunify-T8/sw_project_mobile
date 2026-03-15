import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_status.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/track_metadata_state.dart';
import '../providers/upload_dependencies_provider.dart';
import '../providers/upload_provider.dart';
import '../providers/upload_state.dart';
import '../widgets/home/artist_home_header.dart';
import '../widgets/home/home_cards_grid.dart';
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

  bool _isHomeUploadBusy({
    required UploadState uploadState,
    required TrackMetadataState metadataState,
  }) {
    if (uploadState.isPreparingUpload || uploadState.isUploading) {
      return true;
    }

    if (metadataState.isSaving || metadataState.isPolling) {
      return true;
    }

    return metadataState.processingStatus == UploadStatus.processing;
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
    final metadataState = ref.watch(trackMetadataProvider);
    final artistName = ref.watch(currentArtistNameProvider);

    final isUploadBusy = _isHomeUploadBusy(
      uploadState: uploadState,
      metadataState: metadataState,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ArtistHomeHeader(
                isUploadBusy: isUploadBusy,
                onUploadTap: _startUploadFlow,
              ),
              const SizedBox(height: 18),
              Text(
                artistName,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
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
              const Expanded(
                child: HomeCardsGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}