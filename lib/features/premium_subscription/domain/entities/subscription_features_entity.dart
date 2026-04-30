class SubscriptionFeaturesEntity {
  final int uploadLimit;
  final bool adFree;
  final bool offlineListening;
  final bool limitPlaybackAccess;
  final int playlistLimit;

  const SubscriptionFeaturesEntity({
    this.uploadLimit = 180,
    this.adFree = false,
    this.offlineListening = false,
    this.limitPlaybackAccess = false,
    this.playlistLimit = 3,
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
