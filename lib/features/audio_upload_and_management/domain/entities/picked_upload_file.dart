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