import 'package:flutter/material.dart';
import '../../domain/entities/subscription_tier.dart';

class SubscriptionRestrictionsLink extends StatelessWidget {
  final SubscriptionTier subscriptionPlan;

  const SubscriptionRestrictionsLink({
    super.key,
    required this.subscriptionPlan,
  });

  Widget _buildMenu() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Restrictions Apply",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Subscription may be cancelled at any time in the Google Play Subscription Center. All prices include applicable local sales taxes.",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  (subscriptionPlan == SubscriptionTier.artist)
                      ? 'Artist '
                      : 'Artist Pro ',
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    overlayColor: Colors.transparent,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  child: Text(
                    "Terms of Use",
                    style: TextStyle(color: Color(0xFF4D70AC)),
                  ),
                ),
                Text(' & '),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    overlayColor: Colors.transparent,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  child: Text(
                    "Privacy Policy",
                    style: TextStyle(color: Color(0xFF4D70AC)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Cancel anytime. "),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            overlayColor: Colors.transparent,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF121212),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              constraints: const BoxConstraints(maxHeight: 250),
              showDragHandle: true,
              builder: (_) => _buildMenu(),
            );
          },
          child: const Text(
            "Restrictions apply",
            style: TextStyle(color: Color(0xFF4D70AC)),
          ),
        ),
      ],
    );
  }
}
