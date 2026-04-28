import '../../domain/entities/subscription_plan_entity.dart';
import '../../domain/entities/subscription_tier.dart';
import '../dto/subscription_plan_dto.dart';
import 'subscription_features_mapper.dart';

extension SubscriptionPlanMapper on SubscriptionPlanDto {
  SubscriptionPlanEntity toEntity() {
    return SubscriptionPlanEntity(
      tier: SubscriptionTier.values.byName(name.replaceAll('-', '')),
      monthlyPrice: monthlyPrice,
      yearlyPrice: yearlyPrice,
      currency: currency,
      features: features.toEntity(),
    );
  }
}
