import '../entities/billing_cycle.dart';
import '../entities/current_subscription_entity.dart';
import '../entities/payment_method_entity.dart';
import '../entities/subscription_plan_entity.dart';
import '../entities/subscription_tier.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlanEntity>> getPlans();

  Future<CurrentSubscriptionEntity> getCurrentSubscription();

  Future<CurrentSubscriptionEntity> subscribe({
    required SubscriptionTier tier,
    required BillingCycle billingCycle,
    required PaymentMethodEntity paymentMethod,
    int trialDays = 0,
  });

  Future<DateTime> cancelSubscription();
}