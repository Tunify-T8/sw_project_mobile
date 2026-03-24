/// Preview segment config. Only relevant when playability.status == preview.
class PreviewInfo {
  const PreviewInfo({
    required this.enabled,
    required this.previewDurationSeconds,
    required this.previewStartSeconds,
  });

  final bool enabled;
  final int previewDurationSeconds;
  final int previewStartSeconds;
}
