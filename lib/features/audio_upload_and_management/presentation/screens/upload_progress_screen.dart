import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_status.dart';
import '../providers/library_uploads_provider.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/track_metadata_state.dart';
import '../widgets/upload_progress_status_icon.dart';

/// Shown after the user presses Save on TrackMetadataScreen.
/// Polls backend (via trackMetadataProvider) until status = finished or failed.
/// On finished, refreshes the uploads list then pops to root.
class UploadProgressScreen extends ConsumerWidget {
  const UploadProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackMetadataProvider);

    ref.listen<TrackMetadataState>(trackMetadataProvider, (previous, next) {
      if (previous?.processingStatus == next.processingStatus) return;
      if (next.processingStatus == UploadStatus.finished) {
        ref.read(libraryUploadsProvider.notifier).refresh();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        leading: _showDone(state)
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UploadProgressStatusIcon(
                status: state.processingStatus,
                isSaving: state.isSaving,
              ),
              const SizedBox(height: 32),
              Text(
                _title(state),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _subtitle(state),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              if (_showDone(state))
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          state.processingStatus == UploadStatus.finished
                          ? const Color(0xFFFF5500)
                          : Colors.white24,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    child: Text(
                      state.processingStatus == UploadStatus.finished
                          ? 'View your uploads'
                          : 'Go back',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _showDone(TrackMetadataState state) {
    return state.processingStatus == UploadStatus.finished ||
        state.processingStatus == UploadStatus.failed;
  }

  String _title(TrackMetadataState state) {
    if (state.isSaving) return 'Saving...';
    switch (state.processingStatus) {
      case UploadStatus.idle:
        return 'Starting...';
      case UploadStatus.uploading:
        return 'Uploading audio...';
      case UploadStatus.processing:
        return 'Processing your track...';
      case UploadStatus.finished:
        return 'Track is live!';
      case UploadStatus.failed:
        return 'Processing failed';
      case UploadStatus.deleted:
        return 'Track deleted';
    }
  }

  String _subtitle(TrackMetadataState state) {
    if (state.isSaving) return 'Saving your metadata to the server.';
    switch (state.processingStatus) {
      case UploadStatus.idle:
        return 'Preparing upload...';
      case UploadStatus.uploading:
        return 'Your audio file is being uploaded.';
      case UploadStatus.processing:
        return 'Transcoding and generating waveform.\nThis usually takes under a minute.';
      case UploadStatus.finished:
        return 'Your track has been published successfully.';
      case UploadStatus.failed:
        return state.error ?? 'Something went wrong. Please try again.';
      case UploadStatus.deleted:
        return 'This track has been removed.';
    }
  }
}
