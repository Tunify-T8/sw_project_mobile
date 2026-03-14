class UploadQuota {
  final String tier;
  final int uploadMinutesLimit;
  final int uploadMinutesUsed;
  final int uploadMinutesRemaining;
  final bool canUpgrade;

  const UploadQuota({
    required this.tier,
    required this.uploadMinutesLimit,
    required this.uploadMinutesUsed,
    required this.uploadMinutesRemaining,
    required this.canUpgrade,
  });
}
//the user’s upload allowance