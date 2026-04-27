class SubscriptionFeaturesDto {
  final int maxUploads;
  final bool adFree;
  final bool offlineListening;
  final bool playbackAccess;
  final int playlistLimit;

  SubscriptionFeaturesDto({
    required this.maxUploads,
    required this.adFree,
    required this.offlineListening,
    required this.playbackAccess,
    required this.playlistLimit,
  });

  factory SubscriptionFeaturesDto.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeaturesDto(
      maxUploads: _parseLimit(json['maxUploads'], defaultValue: 180),
      adFree: json['adFree'] ?? false,
      offlineListening: json['offlineListening'] ?? false,
      playbackAccess: json['playbackAccess'] ?? false,
      playlistLimit: _parseLimit(json['playlistLimit'], defaultValue: 3),
    );
  }

  static int _parseLimit(dynamic value, {required int defaultValue}) {
    if (value is num) return value.toInt();
    if (value is String && value.toLowerCase() == 'unlimited') return -1;
    return defaultValue;
  }
}
