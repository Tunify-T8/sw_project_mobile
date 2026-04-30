import 'package:flutter/material.dart';

import '../../../../shared/ui/patterns/error_retry_view.dart';
import '../../domain/entities/billing_cycle.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../providers/subscription_state.dart';
import 'subscription_card.dart';

class SubscriptionPlanContent extends StatelessWidget {
  const SubscriptionPlanContent({
    super.key,
    required this.state,
    required this.paidPlans,
    required this.pageViewController,
    required this.onRetry,
    required this.onPageChanged,
    required this.onSubscribe,
  });

  final SubscriptionState state;
  final List<SubscriptionPlanEntity> paidPlans;
  final PageController pageViewController;
  final VoidCallback onRetry;
  final ValueChanged<int> onPageChanged;
  final Future<String> Function(
    SubscriptionPlanEntity plan,
    BillingCycle billingCycle,
    PaymentMethodEntity paymentMethod,
  ) onSubscribe;

  @override
  Widget build(BuildContext context) {
    if (state.isPlansLoading && !state.hasLoadedPlans) {
      return const Center(
        key: Key('subscription_plans_loading'),
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (state.plansError != null && state.plans.isEmpty) {
      return ErrorRetryView(
        key: const Key('subscription_plans_error_retry'),
        onRetry: onRetry,
      );
    }

    if (paidPlans.isEmpty) {
      return const Center(
        key: Key('subscription_plans_empty'),
        child: Text(
          'No subscription plans available.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return PageView(
      key: const Key('subscription_plans_page_view'),
      controller: pageViewController,
      onPageChanged: onPageChanged,
      children: [
        for (final plan in paidPlans) ...[
          SubscriptionCard(
            key: Key('subscription_card_${plan.tier.name}_monthly'),
            plan: plan,
            subscriptionPeriod: BillingCycle.monthly,
            onSubscribe: (paymentMethod) {
              return onSubscribe(plan, BillingCycle.monthly, paymentMethod);
            },
          ),
          SubscriptionCard(
            key: Key('subscription_card_${plan.tier.name}_yearly'),
            plan: plan,
            subscriptionPeriod: BillingCycle.yearly,
            onSubscribe: (paymentMethod) {
              return onSubscribe(plan, BillingCycle.yearly, paymentMethod);
            },
          ),
        ],
      ],
    );
  }
}
