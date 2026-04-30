import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/subscription_restrictions_link.dart';
import '../../domain/entities/billing_cycle.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../../domain/entities/subscription_tier.dart';
import '../providers/subscription_notifier.dart';
import '../widgets/payment/payment_method_sheet.dart';
import '../widgets/upgrade_image.dart';
import 'subscription_plans_screen.dart';

class UpgradeScreen extends ConsumerStatefulWidget {
  final bool popUp;
  const UpgradeScreen({super.key, required this.popUp});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  Future<void> _openArtistProMonthlyPayment() async {
    final notifier = ref.read(subscriptionNotifierProvider.notifier);
    var state = ref.read(subscriptionNotifierProvider);
    if (state.isPlansLoading) return;

    if (state.plans.isEmpty) {
      await notifier.loadPlans();
      state = ref.read(subscriptionNotifierProvider);
    }

    if (!mounted) return;

    final artistProPlan = _findArtistProPlan(state.plans);
    if (artistProPlan == null) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1C),
          title: const Text(
            'Artist Pro unavailable',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Artist Pro is not available right now.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              key: const Key('artist_pro_unavailable_ok_button'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final price =
        '${artistProPlan.currency} ${artistProPlan.monthlyPrice.toStringAsFixed(2)}/month';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      showDragHandle: true,
      builder: (_) => PaymentMethodSheet(
        price: price,
        onContinue: (paymentMethod) {
          notifier.setBillingCycle(BillingCycle.monthly);
          return notifier.subscribe(
            tier: artistProPlan.tier,
            paymentMethod: paymentMethod,
          );
        },
      ),
    );
  }

  SubscriptionPlanEntity? _findArtistProPlan(
    List<SubscriptionPlanEntity> plans,
  ) {
    for (final plan in plans) {
      if (plan.tier == SubscriptionTier.artistpro) return plan;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final plans = subscriptionState.plans;
    final artistProPlan = _findArtistProPlan(plans);
    final isOpeningPayment = subscriptionState.isPlansLoading;
    final monthlyPriceText = (artistProPlan == null)
        ? 'For EGP 175.00, billed monthly.'
        : 'For ${artistProPlan.currency} ${artistProPlan.monthlyPrice.toStringAsFixed(2)}, billed monthly.';

    return Scaffold(
      key: const Key('upgrade_screen'),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.popUp)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    key: const Key('upgrade_close_button'),
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
          
              const UpgradeImage(key: Key('upgrade_image')),
          
              const SizedBox(height: 20),
          
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color(0xFF2E2E2E),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Color(0xFF988449),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'ARTIST PRO',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color(0xFF044DD2),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            child: Text(
                              'FOR ARTISTS',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
          
                    const SizedBox(height: 18),
          
                    const Text(
                      'Unlock artist tools\n& unlimited\nuploads.',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.05,
                      ),
                    ),
          
                    const SizedBox(height: 18),
          
                    Text(
                      monthlyPriceText,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
          
                    const SizedBox(height: 4),
          
                    const SubscriptionRestrictionsLink(
                      subscriptionPlan: SubscriptionTier.artistpro,
                    ),
          
                    const SizedBox(height: 24),
          
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        key: const Key('upgrade_get_artist_pro_button'),
                        onPressed: isOpeningPayment
                            ? null
                            : _openArtistProMonthlyPayment,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Text(
                          isOpeningPayment ? 'Loading...' : 'Get Artist Pro',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
          
                    const SizedBox(height: 18),
          
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        key: const Key('upgrade_see_all_plans_button'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SubscriptionPlansScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'See all plans',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
