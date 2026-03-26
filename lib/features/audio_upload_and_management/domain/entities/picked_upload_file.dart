// Upload Feature Guide:
// Purpose: Domain model used by the upload feature to keep business data independent from API shapes.
// Used by: cloudinary_upload_repository_impl, cloudinary_upload_workflow, mock_upload_repository_impl, and 6 more upload files.
// Concerns: Multi-format support.
class PickedUploadFile {
  final String name;
  final String path;
  final int sizeBytes;

  /// Null means: we could not read the duration safely.
  final int? durationSeconds;

  const PickedUploadFile({
    required this.name,
    required this.path,
    required this.sizeBytes,
    this.durationSeconds,
  });

  int? get durationMinutesCeil {
    final seconds = durationSeconds;
    if (seconds == null || seconds <= 0) {
      return null;
    }
    return (seconds + 59) ~/ 60;
  }
}
