import 'dart:io';

String? resolveExistingPlaybackLocalFile(String? path) {
  final trimmed = path?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return File(trimmed).existsSync() ? trimmed : null;
}
