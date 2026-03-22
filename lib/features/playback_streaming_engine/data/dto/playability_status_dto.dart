class PlayabilityStatusDto {
  const PlayabilityStatusDto({
    required this.status,
    required this.regionBlocked,
    required this.tierBlocked,
    required this.requiresSubscription,
    this.blockedReason,
  });

  final String status; // 'playable' | 'preview' | 'blocked'
  final bool regionBlocked;
  final bool tierBlocked;
  final bool requiresSubscription;
  final String? blockedReason;

  factory PlayabilityStatusDto.fromJson(Map<String, dynamic> json) {
    return PlayabilityStatusDto(
      status: (json['status'] ?? 'blocked') as String,
      regionBlocked: (json['regionBlocked'] as bool?) ?? false,
      tierBlocked: (json['tierBlocked'] as bool?) ?? false,
      requiresSubscription: (json['requiresSubscription'] as bool?) ?? false,
      blockedReason: json['blockedReason'] as String?,
    );
  }
}
