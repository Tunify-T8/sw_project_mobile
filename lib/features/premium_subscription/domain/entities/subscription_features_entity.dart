class SubscriptionFeaturesEntity {
  final int uploadLimit;
  final bool adFree;
  final bool offlineListening;
  final bool limitPlaybackAccess;
  final int playlistLimit;

  SubscriptionFeaturesEntity({
    required this.uploadLimit,
    required this.adFree,
    required this.offlineListening,
    required this.limitPlaybackAccess,
    required this.playlistLimit,
  });

  SubscriptionFeaturesEntity copyWith({
    int? uploadLimit,
    bool? adFree,
    bool? offlineListening,
    bool? limitPlaybackAccess,
    int? playlistLimit,
  }) {
    return SubscriptionFeaturesEntity(
      uploadLimit: uploadLimit ?? this.uploadLimit,
      adFree: adFree ?? this.adFree,
      offlineListening: offlineListening ?? this.offlineListening,
      limitPlaybackAccess: limitPlaybackAccess ?? this.limitPlaybackAccess,
      playlistLimit: playlistLimit ?? this.playlistLimit,
    );
  }
}
