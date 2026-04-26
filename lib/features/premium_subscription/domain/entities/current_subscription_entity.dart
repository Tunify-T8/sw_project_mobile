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

  CurrentSubscriptionEntity({
    required this.tier,
    required this.status,
    required this.startedAt,
    required this.expiresAt,
    required this.autoRenew,
    required this.features,
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