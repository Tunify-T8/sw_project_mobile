import 'package:flutter/material.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/subscription_restriction_menu.dart';
import '../../domain/entities/subscription_plan.dart';
import 'subscription_plans_screen.dart';

class UpgradeScreen extends StatelessWidget {
  final bool popUp;
  const UpgradeScreen({super.key, required this.popUp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isShort = constraints.maxHeight < 760;
            final isWide = constraints.maxWidth >= 900;
            final artHeight = isShort ? 220.0 : 300.0;
            final artWidth = isShort ? 198.0 : 240.0;
            final cardHeight = isShort ? 190.0 : 260.0;
            final cardWidth = isShort ? 166.0 : 200.0;
            final headlineSize = isShort ? 29.0 : 34.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 720 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (popUp)
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        Center(
                          child: SizedBox(
                            width: artWidth,
                            height: artHeight,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: cardWidth,
                                    height: cardHeight,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF1B3A6B),
                                          Color(0xFF071530),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: isShort ? 12 : 16,
                                  left: 0,
                                  child: Container(
                                    width: cardWidth,
                                    height: cardHeight,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      image: const DecorationImage(
                                        image: NetworkImage(
                                          'https://images.unsplash.com/photo-1575285113814-f770cb8c796e?fm=jpg&q=60&w=3000&auto=format&fit=crop',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isShort ? 12 : 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _PlanPill(
                                    color: const Color(0xFF2E2E2E),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Color(0xFF988449),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'ARTIST PRO',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const _PlanPill(
                                    color: Color(0xFF044DD2),
                                    child: Text(
                                      'FOR ARTISTS',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isShort ? 12 : 18),
                              Text(
                                'Unlock artist tools\n& unlimited\nuploads.',
                                style: TextStyle(
                                  fontSize: headlineSize,
                                  fontWeight: FontWeight.bold,
                                  height: 1.05,
                                ),
                              ),
                              SizedBox(height: isShort ? 12 : 18),
                              const Text(
                                'For EGP 175.00, billed monthly.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text('Cancel anytime. '),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      overlayColor: Colors.transparent,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor:
                                            const Color(0xFF121212),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          maxHeight: 250,
                                        ),
                                        showDragHandle: true,
                                        builder: (_) =>
                                            SubscriptionRestrictionMenu(
                                          subscriptionPlan:
                                              SubscriptionPlan.artistPro,
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Restrictions apply',
                                      style: TextStyle(
                                        color: Color(0xFF4D70AC),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isShort ? 16 : 24),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    minimumSize:
                                        const Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(26),
                                    ),
                                  ),
                                  child: const Text(
                                    'Get Artist Pro',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isShort ? 10 : 18),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SubscriptionPlansScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 48),
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PlanPill extends StatelessWidget {
  const _PlanPill({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: child,
    );
  }
}
