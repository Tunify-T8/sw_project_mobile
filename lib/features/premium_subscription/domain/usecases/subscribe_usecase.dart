import '../../data/dto/subscribe_response_dto.dart';
import '../entities/billing_cycle.dart';
import '../entities/payment_method_entity.dart';
import '../entities/subscription_tier.dart';
import '../repositories/subscription_repository.dart';

class SubscribeUseCase {
  final SubscriptionRepository repository;

  SubscribeUseCase(this.repository);

  Future<SubscribeResponseDto> call({
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
