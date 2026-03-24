// lowkey not gonna happen -> blocked regions and such are premium so we might let this go
class PreviewInfoDto {
  const PreviewInfoDto({
    required this.enabled,
    required this.previewDurationSeconds,
    required this.previewStartSeconds,
  });

  final bool enabled;
  final int previewDurationSeconds;
  final int previewStartSeconds;

  factory PreviewInfoDto.fromJson(Map<String, dynamic> json) {
    return PreviewInfoDto(
      enabled: (json['enabled'] as bool?) ?? false,
      previewDurationSeconds: (json['previewDurationSeconds'] as int?) ?? 30,
      previewStartSeconds: (json['previewStartSeconds'] as int?) ?? 0,
    );
  }
}
