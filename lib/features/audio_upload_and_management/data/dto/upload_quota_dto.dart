class UploadQuotaDto {
  final String tier;
  final int uploadMinutesLimit;
  final int uploadMinutesUsed;
  final int uploadMinutesRemaining;
  final bool canReplaceFiles;
  final bool canScheduleRelease;
  final bool canAccessAdvancedTab;

  UploadQuotaDto({
    required this.tier,
    required this.uploadMinutesLimit,
    required this.uploadMinutesUsed,
    required this.uploadMinutesRemaining,
    required this.canReplaceFiles,
    required this.canScheduleRelease,
    required this.canAccessAdvancedTab,
  });

  factory UploadQuotaDto.fromJson(Map<String, dynamic> json) {
    return UploadQuotaDto(
      tier: json['tier'] as String,
      uploadMinutesLimit: json['uploadMinutesLimit'] as int,
      uploadMinutesUsed: json['uploadMinutesUsed'] as int,
      uploadMinutesRemaining: json['uploadMinutesRemaining'] as int,
      canReplaceFiles: (json['canReplaceFiles'] as bool?) ?? false,
      canScheduleRelease: (json['canScheduleRelease'] as bool?) ?? false,
      canAccessAdvancedTab: (json['canAccessAdvancedTab'] as bool?) ?? false,
    );
  }

  bool get canUpgrade =>
      canReplaceFiles || canScheduleRelease || canAccessAdvancedTab;
}