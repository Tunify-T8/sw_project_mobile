import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/billing_cycle.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../providers/subscription_notifier.dart';
import 'payment/payment_method_sheet.dart';
import 'subscription_restrictions_link.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/entities/subscription_plan_entity.dart';

class SubscriptionCard extends ConsumerWidget {
  final SubscriptionPlanEntity plan;
  final BillingCycle subscriptionPeriod;
  final Future<String> Function(PaymentMethodEntity paymentMethod) onSubscribe;

  const SubscriptionCard({
    super.key,
    required this.plan,
    required this.subscriptionPeriod,
    required this.onSubscribe,
  });

  String _getTitle() {
    switch (plan.tier) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.artist:
        return 'Artist';
      case SubscriptionTier.artistpro:
        return 'Artist Pro';
    }
  }

  String _getPrice() {
    final amount = subscriptionPeriod == BillingCycle.yearly
        ? plan.yearlyPrice
        : plan.monthlyPrice;
    final period = subscriptionPeriod == BillingCycle.yearly ? 'year' : 'month';

    return '${plan.currency} ${amount.toStringAsFixed(2)}/$period';
  }

  List<String> _getFeatures() {
    return [
      (plan.features.uploadLimit > 0)
          ? 'Up to ${plan.features.uploadLimit} minutes of uploads'
          : 'Unlimited uploads',

      if (plan.features.adFree) 'Ad-free listening',
      if (plan.features.offlineListening) 'Offline listening',
      if (plan.features.limitPlaybackAccess) 'Limit playback access',

      (plan.features.playlistLimit > 0)
          ? 'Create up to ${plan.features.playlistLimit} playlists'
          : 'Create unlimited playlists',
    ];
  }

  Widget buildFeatures(String feature) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, color: Color(0xFFE54F03), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            feature,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = _getFeatures();
    final price = _getPrice();
    final currentSubscription = ref
        .watch(subscriptionNotifierProvider)
        .currentSubscription;
    final canSubscribe = (currentSubscription?.tier == SubscriptionTier.free);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xFF044DD2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Text(
                'FOR ARTISTS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SizedBox(height: 14),

          Row(
            children: [
              Text(
                _getTitle(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              SizedBox(width: 8),
              Icon(Icons.star, color: Color(0xFF988449)),
            ],
          ),

          Text(
            price,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          SizedBox(height: 24),

          Column(
            children: features
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: buildFeatures(feature),
                  ),
                )
                .toList(),
          ),

          if (canSubscribe) ...[
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF121212),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    showDragHandle: true,
                    builder: (_) => PaymentMethodSheet(
                      price: price,
                      onContinue: (paymentMethod) {
                        return onSubscribe(paymentMethod);
                      },
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Subscribe Now',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SubscriptionRestrictionsLink(subscriptionPlan: plan.tier),
          ],
        ],
      ),
    );
  }
}
