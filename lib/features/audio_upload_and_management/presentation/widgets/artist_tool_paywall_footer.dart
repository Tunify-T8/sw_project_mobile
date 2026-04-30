// Upload Feature Guide:
// Purpose: Artist tools/paywall widget used around upload quotas and upgrade prompts.
// Used by: artist_tool_paywall_sheet
// Concerns: Supporting UI and infrastructure for upload and track management.
import 'package:flutter/material.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_tier.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/subscription_restrictions_link.dart';

class ArtistToolPaywallFooter extends StatelessWidget {
  const ArtistToolPaywallFooter({
    super.key,
    this.onSubscribe,
    this.isLoading = false,
    this.priceText = 'EGP 164.99/month.',
  });

  final VoidCallback? onSubscribe;
  final bool isLoading;
  final String priceText;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('artist_tool_paywall_footer'),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$priceText ',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        SubscriptionRestrictionsLink(
          key: const Key('artist_tool_paywall_restrictions'),
          subscriptionPlan: SubscriptionTier.artistpro,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            key: const Key('artist_tool_paywall_subscribe_button'),
            onPressed: isLoading ? null : onSubscribe,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 1.5),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              isLoading ? 'Loading...' : 'Subscribe now',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('artist_tool_paywall_maybe_later_button'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Maybe later',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
