import 'subscription_features_entity.dart';
import 'subscription_status.dart';
import 'subscription_tier.dart';

class CurrentSubscriptionEntity {
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final bool autoRenew;
  final SubscriptionFeaturesEntity features;

  const CurrentSubscriptionEntity({
    this.tier = SubscriptionTier.free,
    this.status = SubscriptionStatus.active,
    this.startedAt,
    this.expiresAt,
    this.autoRenew = true,
    this.features = const SubscriptionFeaturesEntity(),
  });

  CurrentSubscriptionEntity copyWith({
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    DateTime? startedAt,
    DateTime? expiresAt,
    bool? autoRenew,
    SubscriptionFeaturesEntity? features,
  }) {
    return CurrentSubscriptionEntity(
      tier: tier ?? this.tier,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      autoRenew: autoRenew ?? this.autoRenew,
      features: features ?? this.features,
    );
  }
}
