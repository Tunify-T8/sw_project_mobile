// Upload Feature Guide:
// Purpose: Domain model used by the upload feature to keep business data independent from API shapes.
// Used by: upload_mappers, upload_api, and 6 more upload files.
// Concerns: Multi-format support.
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

  bool get isUnlimited => tier.toLowerCase() == 'pro';

  int minutesRequiredForDuration(int durationSeconds) {
    if (durationSeconds <= 0) {
      return 0;
    }
    return (durationSeconds + 59) ~/ 60;
  }

  bool canUploadDuration(int durationSeconds) {
    if (isUnlimited) {
      return true;
    }
    return minutesRequiredForDuration(durationSeconds) <=
        uploadMinutesRemaining;
  }

  UploadQuota consumeDuration(int durationSeconds) {
    if (isUnlimited || durationSeconds <= 0) {
      return this;
    }

    final consumedMinutes = minutesRequiredForDuration(durationSeconds);
    final nextUsed = uploadMinutesUsed + consumedMinutes > uploadMinutesLimit
        ? uploadMinutesLimit
        : uploadMinutesUsed + consumedMinutes;
    final nextRemaining = uploadMinutesLimit - nextUsed;

    return UploadQuota(
      tier: tier,
      uploadMinutesLimit: uploadMinutesLimit,
      uploadMinutesUsed: nextUsed,
      uploadMinutesRemaining: nextRemaining,
      canReplaceFiles: canReplaceFiles,
      canScheduleRelease: canScheduleRelease,
      canAccessAdvancedTab: canAccessAdvancedTab,
    );
  }
}
