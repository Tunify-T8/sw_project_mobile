import 'package:flutter/material.dart';
import '../../domain/entities/billing_cycle.dart';
import 'subscription_restriction_menu.dart';
import '../../domain/entities/subscription_tier.dart';

class SubscriptionCard extends StatelessWidget {
  static const yearlyPrice = 'EGP 1,055.00/year';
  static const monthlyPrice = 'EGP 175.00/month';
  static const List<String> features = [
    'Unlock unlimited upload time',
    'Get paid fairly for your plays',
    'Access advanced audience insights',
    'Replace your track without losing its stats',
    'Pin your favorite tracks',
  ];
  final BillingCycle subscriptionPeriod;
  const SubscriptionCard({super.key, required this.subscriptionPeriod});

  Widget buildFeatures({required String feature}) {
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
  Widget build(BuildContext context) {
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
                "Artist Pro",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              SizedBox(width: 8),
              Icon(Icons.star, color: Color(0xFF988449)),
            ],
          ),
          Text(
            (subscriptionPeriod == BillingCycle.yearly)
                ? yearlyPrice
                : monthlyPrice,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 24),
          Column(
            children: features
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: buildFeatures(feature: feature),
                  ),
                )
                .toList(),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Row(
            children: [
              Text("Cancel anytime. "),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  overlayColor: Colors.transparent,
                ),
                onPressed: () {
                  showModalBottomSheet(
                            context: context,
                            backgroundColor: Color(0xFF121212),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            constraints: BoxConstraints(maxHeight: 250),
                            showDragHandle: true,
                            builder: (_) => SubscriptionRestrictionMenu(
                              subscriptionPlan: SubscriptionTier.artistPro,
                            ),
                          );
                },
                child: const Text(
                  "Restrictions apply",
                  style: TextStyle(color: Color(0xFF4D70AC)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
