// Upload Feature Guide:
// Purpose: Presentational widget for upload progress, upload artwork, or other upload-specific UI states.
// Used by: track_metadata_header, track_checklist_sheet
// Concerns: Multi-format support; Transcoding logic.
import 'package:flutter/material.dart';

class UploadChecklistProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;

  const UploadChecklistProgressRing({
    super.key,
    required this.progress,
    this.size = 28,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0).toDouble();

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: normalizedProgress,
        strokeWidth: strokeWidth,
        backgroundColor: Colors.white12,
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA855F7)),
      ),
    );
  }
}
