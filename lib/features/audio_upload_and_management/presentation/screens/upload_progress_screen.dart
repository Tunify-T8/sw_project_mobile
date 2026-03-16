import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_status.dart';
import '../providers/track_metadata_provider.dart';
import '../providers/track_metadata_state.dart';
import '../providers/library_uploads_provider.dart';

/// Shown after the user presses Save on TrackMetadataScreen.
/// Polls backend (via trackMetadataProvider) until status = finished or failed.
/// On finished → refreshes the uploads list then pops to root.
class UploadProgressScreen extends ConsumerWidget {
  const UploadProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackMetadataProvider);

    // Auto-navigate when processing finishes
    ref.listen<TrackMetadataState>(trackMetadataProvider, (prev, next) {
      if (prev?.processingStatus == next.processingStatus) return;

      if (next.processingStatus == UploadStatus.finished) {
        // Refresh library so new track appears in YourUploads
        ref.read(libraryUploadsProvider.notifier).refresh();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        leading: state.processingStatus == UploadStatus.finished ||
                state.processingStatus == UploadStatus.failed
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatusIcon(status: state.processingStatus, isSaving: state.isSaving),
              const SizedBox(height: 32),
              Text(
                _title(state),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                _subtitle(state),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 14, height: 1.5),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Text(state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ),
              ],
              const SizedBox(height: 48),
              if (_showDone(state))
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.processingStatus == UploadStatus.finished
                          ? const Color(0xFFFF5500)
                          : Colors.white24,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    child: Text(
                      state.processingStatus == UploadStatus.finished
                          ? 'View your uploads'
                          : 'Go back',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _showDone(TrackMetadataState s) =>
      s.processingStatus == UploadStatus.finished ||
      s.processingStatus == UploadStatus.failed;

  String _title(TrackMetadataState s) {
    if (s.isSaving) return 'Saving…';
    switch (s.processingStatus) {
      case UploadStatus.idle:
        return 'Starting…';
      case UploadStatus.uploading:
        return 'Uploading audio…';
      case UploadStatus.processing:
        return 'Processing your track…';
      case UploadStatus.finished:
        return '🎉 Track is live!';
      case UploadStatus.failed:
        return 'Processing failed';
      case UploadStatus.deleted:
        return 'Track deleted';
    }
  }

  String _subtitle(TrackMetadataState s) {
    if (s.isSaving) return 'Saving your metadata to the server.';
    switch (s.processingStatus) {
      case UploadStatus.idle:
        return 'Preparing upload…';
      case UploadStatus.uploading:
        return 'Your audio file is being uploaded.';
      case UploadStatus.processing:
        return 'Transcoding and generating waveform.\nThis usually takes under a minute.';
      case UploadStatus.finished:
        return 'Your track has been published successfully.';
      case UploadStatus.failed:
        return s.error ?? 'Something went wrong. Please try again.';
      case UploadStatus.deleted:
        return 'This track has been removed.';
    }
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, required this.isSaving});
  final UploadStatus status;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final spinning = isSaving ||
        status == UploadStatus.idle ||
        status == UploadStatus.uploading ||
        status == UploadStatus.processing;

    if (spinning) {
      return const SizedBox(
        width: 72,
        height: 72,
        child: CircularProgressIndicator(color: Color(0xFFFF5500), strokeWidth: 4),
      );
    }

    final (icon, color) = switch (status) {
      UploadStatus.finished => (Icons.check_circle_outline_rounded, const Color(0xFF4CAF50)),
      UploadStatus.failed => (Icons.error_outline_rounded, Colors.redAccent),
      _ => (Icons.hourglass_empty_rounded, Colors.white38),
    };

    return Icon(icon, size: 72, color: color);
  }
}
