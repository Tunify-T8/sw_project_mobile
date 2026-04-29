import 'package:software_project/features/premium_subscription/data/dto/cancel_subscription_response_dto.dart';
import 'package:software_project/features/premium_subscription/data/dto/subscribe_response_dto.dart';
import 'package:software_project/features/premium_subscription/domain/entities/billing_cycle.dart';
import 'package:software_project/features/premium_subscription/domain/entities/current_subscription_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/payment_method_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/payment_method_type.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_features_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_plan_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_status.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_tier.dart';
import 'package:software_project/features/premium_subscription/domain/repositories/subscription_repository.dart';

SubscriptionFeaturesEntity premiumFeatures({
  int uploadLimit = -1,
  bool adFree = true,
  bool offlineListening = true,
  bool limitPlaybackAccess = true,
  int playlistLimit = -1,
}) {
  return SubscriptionFeaturesEntity(
    uploadLimit: uploadLimit,
    adFree: adFree,
    offlineListening: offlineListening,
    limitPlaybackAccess: limitPlaybackAccess,
    playlistLimit: playlistLimit,
  );
}

SubscriptionPlanEntity artistPlan() {
  return SubscriptionPlanEntity(
    tier: SubscriptionTier.artist,
    monthlyPrice: 99,
    yearlyPrice: 990,
    currency: 'EGP',
    features: premiumFeatures(uploadLimit: 360, playlistLimit: 20),
  );
}

SubscriptionPlanEntity artistProPlan() {
  return SubscriptionPlanEntity(
    tier: SubscriptionTier.artistpro,
    monthlyPrice: 175,
    yearlyPrice: 1750,
    currency: 'EGP',
    features: premiumFeatures(),
  );
}

CurrentSubscriptionEntity freeSubscription() {
  return const CurrentSubscriptionEntity(
    tier: SubscriptionTier.free,
    features: SubscriptionFeaturesEntity(),
  );
}

CurrentSubscriptionEntity activeArtistProSubscription() {
  return CurrentSubscriptionEntity(
    tier: SubscriptionTier.artistpro,
    status: SubscriptionStatus.active,
    startedAt: DateTime(2026, 1, 1),
    expiresAt: DateTime(2026, 5, 15),
    autoRenew: true,
    features: premiumFeatures(),
  );
}

const cardPaymentMethod = PaymentMethodEntity(
  type: PaymentMethodType.card,
  brand: 'visa',
  last4: '1111',
  expiryMonth: 12,
  expiryYear: 2030,
);

class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository({
    List<SubscriptionPlanEntity>? plans,
    CurrentSubscriptionEntity? currentSubscription,
    this.plansError,
    this.currentError,
    this.subscribeError,
    this.cancelError,
    this.subscribeMessage = 'Subscription activated',
    this.cancelMessage = 'Subscription cancelled',
  }) : plans = plans ?? [artistPlan(), artistProPlan()],
       currentSubscription = currentSubscription ?? freeSubscription();

  List<SubscriptionPlanEntity> plans;
  CurrentSubscriptionEntity currentSubscription;
  Object? plansError;
  Object? currentError;
  Object? subscribeError;
  Object? cancelError;
  String subscribeMessage;
  String cancelMessage;

  SubscriptionTier? lastTier;
  BillingCycle? lastBillingCycle;
  PaymentMethodEntity? lastPaymentMethod;
  int? lastTrialDays;
  int getPlansCalls = 0;
  int getCurrentCalls = 0;
  int subscribeCalls = 0;
  int cancelCalls = 0;

  @override
  Future<List<SubscriptionPlanEntity>> getPlans() async {
    getPlansCalls++;
    final error = plansError;
    if (error != null) throw error;
    return plans;
  }

  @override
  Future<CurrentSubscriptionEntity> getCurrentSubscription() async {
    getCurrentCalls++;
    final error = currentError;
    if (error != null) throw error;
    return currentSubscription;
  }

  @override
  Future<SubscribeResponseDto> subscribe({
    required SubscriptionTier tier,
    required BillingCycle billingCycle,
    required PaymentMethodEntity paymentMethod,
    int trialDays = 0,
  }) async {
    subscribeCalls++;
    lastTier = tier;
    lastBillingCycle = billingCycle;
    lastPaymentMethod = paymentMethod;
    lastTrialDays = trialDays;
    final error = subscribeError;
    if (error != null) throw error;
    currentSubscription = activeArtistProSubscription();
    return SubscribeResponseDto(message: subscribeMessage);
  }

  @override
  Future<CancelSubscriptionResponseDto> cancelSubscription() async {
    cancelCalls++;
    final error = cancelError;
    if (error != null) throw error;
    currentSubscription = freeSubscription();
    return CancelSubscriptionResponseDto(
      message: cancelMessage,
      expiresAt: '2026-05-15T00:00:00Z',
    );
  }
}
