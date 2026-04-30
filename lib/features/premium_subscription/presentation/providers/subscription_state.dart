import '../../domain/entities/billing_cycle.dart';
import '../../domain/entities/current_subscription_entity.dart';
import '../../domain/entities/subscription_plan_entity.dart';

class SubscriptionState {
  final List<SubscriptionPlanEntity> plans;
  final CurrentSubscriptionEntity currentSubscription;

  final bool isPlansLoading;
  final bool isCurrentLoading;
  final bool isSubscribing;
  final bool isCancelling;

  final bool hasLoadedPlans;
  final bool hasLoadedCurrent;

  final BillingCycle selectedBillingCycle;

  final String? plansError;
  final String? currentError;
  final String? actionError;
  final String? actionMessage;

  SubscriptionState({
    this.plans = const [],
    this.currentSubscription = const CurrentSubscriptionEntity(),
    this.isPlansLoading = false,
    this.isCurrentLoading = false,
    this.isSubscribing = false,
    this.isCancelling = false,
    this.hasLoadedPlans = false,
    this.hasLoadedCurrent = false,
    this.selectedBillingCycle = BillingCycle.monthly,
    this.plansError,
    this.currentError,
    this.actionError,
    this.actionMessage,
  });

  SubscriptionState copyWith({
    List<SubscriptionPlanEntity>? plans,
    CurrentSubscriptionEntity? currentSubscription,
    bool? isPlansLoading,
    bool? isCurrentLoading,
    bool? isSubscribing,
    bool? isCancelling,
    bool? hasLoadedPlans,
    bool? hasLoadedCurrent,
    BillingCycle? selectedBillingCycle,
    String? plansError,
    String? currentError,
    String? actionError,
    String? actionMessage,
  }) {
    return SubscriptionState(
      plans: plans ?? this.plans,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      isPlansLoading: isPlansLoading ?? this.isPlansLoading,
      isCurrentLoading: isCurrentLoading ?? this.isCurrentLoading,
      isSubscribing: isSubscribing ?? this.isSubscribing,
      isCancelling: isCancelling ?? this.isCancelling,
      hasLoadedPlans: hasLoadedPlans ?? this.hasLoadedPlans,
      hasLoadedCurrent: hasLoadedCurrent ?? this.hasLoadedCurrent,
      selectedBillingCycle: selectedBillingCycle ?? this.selectedBillingCycle,
      plansError: plansError,
      currentError: currentError,
      actionError: actionError,
      actionMessage: actionMessage,
    );
  }
}
