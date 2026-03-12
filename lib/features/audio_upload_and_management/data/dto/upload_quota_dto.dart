class UploadQuotaDto {
  final String tier;
  final int uploadMinutesLimit;
  final int uploadMinutesUsed;
  final int uploadMinutesRemaining;
  final bool canUpgrade;

  UploadQuotaDto({
    required this.tier,
    required this.uploadMinutesLimit,
    required this.uploadMinutesUsed,
    required this.uploadMinutesRemaining,
    required this.canUpgrade,
  });

  factory UploadQuotaDto.fromJson(Map<String, dynamic> json) {
    return UploadQuotaDto(
      tier: json['tier'] as String,
      uploadMinutesLimit: json['uploadMinutesLimit'] as int,
      uploadMinutesUsed: json['uploadMinutesUsed'] as int,
      uploadMinutesRemaining: json['uploadMinutesRemaining'] as int,
      canUpgrade: json['canUpgrade'] as bool,
    );
  }
}