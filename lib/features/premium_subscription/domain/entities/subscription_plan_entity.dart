import 'subscription_features_entity.dart';
import 'subscription_tier.dart';

class SubscriptionPlanEntity {
  final SubscriptionTier tier;
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final SubscriptionFeaturesEntity features;

  SubscriptionPlanEntity({
    required this.tier,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.features,
  });
  
  SubscriptionPlanEntity copyWith({
    SubscriptionTier? tier,
    double? monthlyPrice,
    double? yearlyPrice,
    String? currency,
    SubscriptionFeaturesEntity? features,
  }) {
    return SubscriptionPlanEntity(
      tier: tier ?? this.tier,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      currency: currency ?? this.currency,
      features: features ?? this.features,
    );
  }
}
