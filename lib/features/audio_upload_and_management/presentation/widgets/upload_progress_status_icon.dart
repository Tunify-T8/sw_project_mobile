import 'package:flutter/material.dart';

import '../../domain/entities/upload_status.dart';

class UploadProgressStatusIcon extends StatelessWidget {
  const UploadProgressStatusIcon({
    super.key,
    required this.status,
    required this.isSaving,
  });

  final UploadStatus status;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final spinning =
        isSaving ||
        status == UploadStatus.idle ||
        status == UploadStatus.uploading ||
        status == UploadStatus.processing;

    if (spinning) {
      return const SizedBox(
        width: 72,
        height: 72,
        child: CircularProgressIndicator(
          color: Color(0xFFFF5500),
          strokeWidth: 4,
        ),
      );
    }

    final (icon, color) = switch (status) {
      UploadStatus.finished => (
        Icons.check_circle_outline_rounded,
        const Color(0xFF4CAF50),
      ),
      UploadStatus.failed => (Icons.error_outline_rounded, Colors.redAccent),
      _ => (Icons.hourglass_empty_rounded, Colors.white38),
    };

    return Icon(icon, size: 72, color: color);
  }
}
