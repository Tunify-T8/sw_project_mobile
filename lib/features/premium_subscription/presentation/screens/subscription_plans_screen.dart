import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_notifier.dart';
import '../widgets/faq_section.dart';
import '../widgets/subscription_plan_content.dart';
import '../widgets/subscription_testimonial.dart';
import '../../domain/entities/subscription_tier.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  TabController? _tabController;
  int _tabCount = 0;

  static const TextStyle _titleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle _subtitleTextStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
  );

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();

    Future.microtask(() {
      ref.read(subscriptionNotifierProvider.notifier).loadPlans();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController?.dispose();
  }

  void _syncTabController(int count) {
    if (_tabCount == count) return;

    _tabController?.dispose();
    _tabController = TabController(length: count, vsync: this);
    _tabCount = count;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionNotifierProvider);
    final paidPlans = state.plans
        .where((plan) => plan.tier != SubscriptionTier.free)
        .toList();

    final cardCount = paidPlans.length * 2;
    if (cardCount > 0) {
      _syncTabController(cardCount);
    }

    return Scaffold(
      key: const Key('subscription_plans_screen'),
      backgroundColor: Colors.black,
      body: ListView(
        key: const Key('subscription_plans_scroll'),
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5B1E8C), Color(0xFFD4186C)],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      key: const Key('subscription_plans_close_button'),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "What's next in music is first on SoundCloud",
                          style: _titleTextStyle,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Whether you want to share your sound or enjoy ad-free listening, we have the right plan for you.',
                          style: _subtitleTextStyle,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: SizedBox(
                      height: 450,
                      width: 380,
                      child: SubscriptionPlanContent(
                        key: const Key('subscription_plan_content'),
                        state: state,
                        paidPlans: paidPlans,
                        pageViewController: _pageViewController,
                        onRetry: () {
                          ref
                              .read(subscriptionNotifierProvider.notifier)
                              .loadPlans();
                        },
                        onPageChanged: (index) {
                          setState(() {
                            _tabController?.index = index;
                          });
                        },
                        onSubscribe: (plan, billingCycle, paymentMethod) {
                          final notifier = ref.read(
                            subscriptionNotifierProvider.notifier,
                          );
                          notifier.setBillingCycle(billingCycle);
                          return notifier.subscribe(
                            tier: plan.tier,
                            paymentMethod: paymentMethod,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_tabController != null)
                    Center(
                      key: const Key('subscription_plan_page_indicator'),
                      child: TabPageSelector(
                        controller: _tabController!,
                        color: const Color(0xFF7A2D63),
                        selectedColor: const Color(0xFF111111),
                        borderStyle: BorderStyle.none,
                        indicatorSize: 8,
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "SoundCloud supports independent artists",
                  style: _titleTextStyle,
                ),
                SizedBox(height: 10),
                Text(
                  'From fan-powered royalties to our audience-building artists plans, your subscription helps support the SoundCloud global community.',
                  style: _subtitleTextStyle,
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          SubscriptionTestimonial(key: const Key('subscription_testimonial')),

          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FaqSection(key: const Key('subscription_faq_section')),
          ),
        ],
      ),
    );
  }
}
