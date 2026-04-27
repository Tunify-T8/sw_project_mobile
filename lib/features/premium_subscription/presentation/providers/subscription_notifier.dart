import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/billing_cycle.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/subscription_tier.dart';
import 'subscription_provider.dart';
import 'subscription_state.dart';

final subscriptionNotifierProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() => SubscriptionState();

  Future<void> loadPlans() async {
    state = state.copyWith(
      isPlansLoading: true,
      plansError: null,
      actionError: null,
      actionMessage: null,
    );

    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      final plans = await repository.getPlans();

      state = state.copyWith(
        plans: plans,
        isPlansLoading: false,
        hasLoadedPlans: true,
        plansError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isPlansLoading: false,
        hasLoadedPlans: true,
        plansError: e.toString(),
      );
    }
  }

  Future<void> loadCurrentSubscription() async {
    state = state.copyWith(
      isCurrentLoading: true,
      currentError: null,
      actionError: null,
      actionMessage: null,
    );

    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      final currentSubscription = await repository.getCurrentSubscription();

      state = state.copyWith(
        currentSubscription: currentSubscription,
        isCurrentLoading: false,
        hasLoadedCurrent: true,
        currentError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isCurrentLoading: false,
        hasLoadedCurrent: true,
        currentError: e.toString(),
      );
    }
  }

  Future<String> subscribe({
    required SubscriptionTier tier,
    required PaymentMethodEntity paymentMethod,
    int trialDays = 0,
  }) async {
    state = state.copyWith(
      isSubscribing: true,
      actionError: null,
      actionMessage: null,
    );

    try {
      final repository = ref.read(subscriptionRepositoryProvider);

      final response = await repository.subscribe(
        tier: tier,
        billingCycle: state.selectedBillingCycle,
        paymentMethod: paymentMethod,
        trialDays: trialDays,
      );

      state = state.copyWith(
        isSubscribing: false,
        actionError: null,
        actionMessage: response.message,
      );

      try {
        await loadCurrentSubscription();
      } catch (_) {}

      return response.message;
    } catch (e) {
      state = state.copyWith(
        isSubscribing: false,
        actionError: e.toString(),
      );
      throw Exception(e.toString());
    }
  }

  Future<void> cancelSubscription() async {
    state = state.copyWith(
      isCancelling: true,
      actionError: null,
      actionMessage: null,
    );

    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      final response = await repository.cancelSubscription();

      state = state.copyWith(
        isCancelling: false,
        actionError: null,
        actionMessage: response.message,
      );

      await loadCurrentSubscription();
    } catch (e) {
      state = state.copyWith(
        isCancelling: false,
        actionError: e.toString(),
      );
    }
  }

  void setBillingCycle(BillingCycle billingCycle) {
    state = state.copyWith(selectedBillingCycle: billingCycle);
  }

  void clearActionMessage() {
    state = state.copyWith(
      actionError: null,
      actionMessage: null,
    );
  }
}
