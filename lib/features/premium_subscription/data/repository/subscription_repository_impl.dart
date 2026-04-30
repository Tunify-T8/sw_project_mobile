import 'package:software_project/features/premium_subscription/data/api/subscription_api.dart';
import 'package:software_project/features/premium_subscription/domain/entities/billing_cycle.dart';
import 'package:software_project/features/premium_subscription/domain/entities/current_subscription_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/payment_method_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_plan_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_tier.dart';
import 'package:software_project/features/premium_subscription/domain/repositories/subscription_repository.dart';
import '../dto/cancel_subscription_response_dto.dart';
import '../dto/subscribe_request_dto.dart';
import '../dto/subscribe_response_dto.dart';
import '../mappers/subscription_plan_mapper.dart';
import '../mappers/current_subscription_mapper.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionApi api;

  SubscriptionRepositoryImpl(this.api);

  @override
  Future<List<SubscriptionPlanEntity>> getPlans() async {
    final dtos = await api.getSubscriptionPlans();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<CurrentSubscriptionEntity> getCurrentSubscription() async {
    final dto = await api.getCurrentSubscription();
    return dto.toEntity();
  }

  @override
  Future<SubscribeResponseDto> subscribe({
    required SubscriptionTier tier,
    required BillingCycle billingCycle,
    required PaymentMethodEntity paymentMethod,
    int trialDays = 0,
  }) {
    final String planName;
    if (tier == SubscriptionTier.artistpro) {
      planName = 'artist-pro';
    } else {
      planName = tier.name;
    }
    print(planName);
    return api.subscribe(
      request: SubscribeRequestDto(
        plan: planName,
        billingCycle: billingCycle.name,
        paymentMethod: paymentMethod.type.name,
        card: paymentMethod.type.name == 'card'
            ? {
                'last4': paymentMethod.last4,
                'brand': paymentMethod.brand,
                'expiryMonth': paymentMethod.expiryMonth,
                'expiryYear': paymentMethod.expiryYear,
              }
            : null,
        trialDays: trialDays,
      ),
    );
  }

  @override
  Future<CancelSubscriptionResponseDto> cancelSubscription() {
    return api.cancelSubscription();
  }
}
