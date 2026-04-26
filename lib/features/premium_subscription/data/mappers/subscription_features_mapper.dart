import '../../domain/entities/subscription_features_entity.dart';
import '../dto/subscription_features_dto.dart';

extension SubscriptionFeaturesMapper on SubscriptionFeaturesDto {
  SubscriptionFeaturesEntity toEntity() {
    return SubscriptionFeaturesEntity(
      uploadLimit: maxUploads,
      adFree: adFree,
      offlineListening: offlineListening,
      limitPlaybackAccess: playbackAccess,
      playlistLimit: playlistLimit,
    );
  }
}