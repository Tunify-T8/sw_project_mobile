import '../entities/billing_cycle.dart';
import '../entities/current_subscription_entity.dart';
import '../entities/payment_method_entity.dart';
import '../entities/subscription_tier.dart';
import '../repositories/subscription_repository.dart';

class SubscribeUseCase {
  final SubscriptionRepository repository;

  SubscribeUseCase(this.repository);

  Future<CurrentSubscriptionEntity> call({
    required SubscriptionTier tier,
    required BillingCycle billingCycle,
    required PaymentMethodEntity paymentMethod,
    int trialDays = 0,
  }) {
    return repository.subscribe(
      tier: tier,
      billingCycle: billingCycle,
      paymentMethod: paymentMethod,
      trialDays: trialDays,
    );
  }
}