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
      maxUploads: json['maxUploads'],
      adFree: json['adFree'] ?? false,
      offlineListening: json['offlineListening'] ?? false,
      playbackAccess: json['playbackAccess'] ?? false,
      playlistLimit: json['playlistLimit'],
    );
  }
}