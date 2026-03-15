class UploadQuota {
  final String tier;
  final int uploadMinutesLimit;
  final int uploadMinutesUsed;
  final int uploadMinutesRemaining;

  final bool canReplaceFiles;
  final bool canScheduleRelease;
  final bool canAccessAdvancedTab;

  const UploadQuota({
    required this.tier,
    required this.uploadMinutesLimit,
    required this.uploadMinutesUsed,
    required this.uploadMinutesRemaining,
    required this.canReplaceFiles,
    required this.canScheduleRelease,
    required this.canAccessAdvancedTab,
  });

  bool get canUpgrade =>
      canReplaceFiles || canScheduleRelease || canAccessAdvancedTab;
}