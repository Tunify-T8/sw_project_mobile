// Upload Feature Guide:
// Purpose: UI utility/helper used by upload screens or widgets.
// Used by: artist_home_screen, home_screen, your_uploads_screen
// Concerns: Multi-format support.
import 'package:flutter/material.dart';

void showUploadErrorSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: const Color(0xFF1C1C1E),
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
