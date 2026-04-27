import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/current_subscription_entity.dart';
import '../../domain/entities/subscription_features_entity.dart';
import '../../domain/entities/subscription_tier.dart';
import '../providers/subscription_notifier.dart';
import '../widgets/upgrade_image.dart';
import 'subscription_plans_screen.dart';

class CurrentSubscriptionScreen extends ConsumerWidget {
  const CurrentSubscriptionScreen({super.key});

  String _planName(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.artist:
        return 'Artist';
      case SubscriptionTier.artistpro:
        return 'Artist Pro';
    }
  }

  String _billingLabel(CurrentSubscriptionEntity subscription) {
    final date = subscription.expiresAt;
    if (date == null) {
      return subscription.autoRenew
          ? 'Renews: Not scheduled'
          : 'Active until: Not scheduled';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final formattedDate = '${months[date.month - 1]} ${date.day}, ${date.year}';
    return subscription.autoRenew
        ? 'Renews $formattedDate'
        : 'Active until $formattedDate';
  }

  List<String> _featureLabels(SubscriptionFeaturesEntity features) {
    return [
      features.uploadLimit > 0
          ? 'Up to ${features.uploadLimit} minutes of uploads'
          : 'Unlimited uploads',
      if (features.adFree) 'Ad-free listening',
      if (features.offlineListening) 'Offline listening',
      if (features.limitPlaybackAccess) 'Limit playback access',
      features.playlistLimit > 0
          ? 'Create up to ${features.playlistLimit} playlists'
          : 'Unlimited playlists',
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionNotifierProvider);
    final subscription = state.currentSubscription;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UpgradeImage(),

              if (subscription == null)
                const Text(
                  'No current subscription found.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                )
              else ...[
                Text(
                  _planName(subscription.tier),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    height: 1.05,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _billingLabel(subscription),
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),

                const SizedBox(height: 15),

                for (final feature in _featureLabels(subscription.features))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check,
                          color: Color(0xFFFF5500),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feature,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionPlansScreen(),
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
                    'See more plans',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: state.isCancelling
                      ? null
                      : () => ref
                            .read(subscriptionNotifierProvider.notifier)
                            .cancelSubscription(),
                  child: Text(
                    state.isCancelling
                        ? 'Cancelling...'
                        : 'Cancel Subscription',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
