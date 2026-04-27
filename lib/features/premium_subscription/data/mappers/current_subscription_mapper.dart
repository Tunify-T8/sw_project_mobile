import '../../domain/entities/current_subscription_entity.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/entities/subscription_tier.dart';
import '../dto/current_subscription_dto.dart';
import 'subscription_features_mapper.dart';

extension CurrentSubscriptionMapper on CurrentSubscriptionDto {
  CurrentSubscriptionEntity toEntity() {
    return CurrentSubscriptionEntity(
      tier: SubscriptionTier.values.byName(plan),
      status: SubscriptionStatus.values.byName(status),
      startedAt: (startedAt == null) ? null : DateTime.tryParse(startedAt!),
      expiresAt: (expiresAt == null )? null : DateTime.tryParse(expiresAt!),
      autoRenew: autoRenew,
      features: features.toEntity(),
    );
  }
}