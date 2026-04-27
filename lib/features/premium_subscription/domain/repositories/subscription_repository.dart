import '../../data/dto/cancel_subscription_response_dto.dart';
import '../../data/dto/subscribe_response_dto.dart';
import '../entities/billing_cycle.dart';
import '../entities/current_subscription_entity.dart';
import '../entities/payment_method_entity.dart';
import '../entities/subscription_plan_entity.dart';
import '../entities/subscription_tier.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlanEntity>> getPlans();

  Future<CurrentSubscriptionEntity> getCurrentSubscription();

  Future<SubscribeResponseDto> subscribe({
    required SubscriptionTier tier,
    required BillingCycle billingCycle,
    required PaymentMethodEntity paymentMethod,
    int trialDays = 0,
  });

  Future<CancelSubscriptionResponseDto> cancelSubscription();
}
