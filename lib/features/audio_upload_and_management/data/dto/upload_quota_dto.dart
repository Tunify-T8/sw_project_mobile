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
    // Handles both response shapes:
    //
    // GET /users/me/upload (not fully implemented by backend):
    //   { tier, uploadMinutesLimit, uploadMinutesUsed, uploadMinutesRemaining,
    //     canReplaceFiles, canScheduleRelease, canAccessAdvancedTab }
    //
    // GET /users/:id/artist-tools/upload-minutes (currently used):
    //   { tier, uploadMinutesLimit, uploadMinutesUsed, uploadMinutesRemaining,
    //     canReplaceFiles, canUpgrade }
    //
    // Both may return null for limit/remaining when backend hasn't computed them.

    final limit = (json['uploadMinutesLimit'] as num?)?.toInt() ?? 180;
    final used = (json['uploadMinutesUsed'] as num?)?.toInt() ?? 0;

    // Compute remaining: use server value if provided, otherwise derive it.
    final serverRemaining =
        (json['uploadMinutesRemaining'] as num?)?.toInt();
    final remaining = serverRemaining ?? (limit - used).clamp(0, limit);

    // canReplaceFiles comes from both endpoints.
    // canUpgrade from artist-tools implies at least canReplaceFiles.
    final canUpgrade = (json['canUpgrade'] as bool?) ?? false;
    final canReplaceFiles =
        (json['canReplaceFiles'] as bool?) ?? canUpgrade;

    return UploadQuotaDto(
      tier: (json['tier'] as String?) ?? 'free',
      uploadMinutesLimit: limit,
      uploadMinutesUsed: used,
      uploadMinutesRemaining: remaining,
      canReplaceFiles: canReplaceFiles,
      canScheduleRelease: (json['canScheduleRelease'] as bool?) ?? false,
      canAccessAdvancedTab: (json['canAccessAdvancedTab'] as bool?) ?? false,
    );
  }

  bool get canUpgrade =>
      canReplaceFiles || canScheduleRelease || canAccessAdvancedTab;
}