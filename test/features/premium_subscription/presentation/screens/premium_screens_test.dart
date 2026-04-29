import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/premium_subscription/domain/entities/billing_cycle.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_tier.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/subscription_notifier.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/subscription_provider.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/subscription_state.dart';
import 'package:software_project/features/premium_subscription/presentation/screens/current_subscription_screen.dart';
import 'package:software_project/features/premium_subscription/presentation/screens/subscription_plans_screen.dart';
import 'package:software_project/features/premium_subscription/presentation/screens/upgrade_screen.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/payment/payment_method_sheet.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/subscription_plan_content.dart';

import '../../../../test_utils/mock_network_images.dart';
import '../../helpers/premium_test_data.dart';

class InitialSubscriptionNotifier extends SubscriptionNotifier {
  InitialSubscriptionNotifier(this.initial);

  final SubscriptionState initial;

  @override
  SubscriptionState build() => initial;
}

Future<void> pumpPremiumScreen(
  WidgetTester tester,
  Widget screen, {
  FakeSubscriptionRepository? repository,
  SubscriptionState? initialState,
}) {
  return mockNetworkImagesFor(() {
    final fakeRepository = repository ?? FakeSubscriptionRepository();
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(fakeRepository),
          if (initialState != null)
            subscriptionNotifierProvider.overrideWith(
              () => InitialSubscriptionNotifier(initialState),
            ),
        ],
        child: MaterialApp(home: screen),
      ),
    );
  });
}

void main() {
  void useLargeViewport(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('upgrade screen opens payment and navigates to all plans', (
    tester,
  ) async {
    useLargeViewport(tester);
    final repository = FakeSubscriptionRepository();

    await pumpPremiumScreen(
      tester,
      const UpgradeScreen(popUp: true),
      repository: repository,
      initialState: SubscriptionState(
        plans: [artistPlan(), artistProPlan()],
        currentSubscription: activeArtistProSubscription(),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('upgrade_screen')), findsOneWidget);
    expect(find.byKey(const Key('upgrade_close_button')), findsOneWidget);
    expect(
      find.byKey(const Key('upgrade_get_artist_pro_button')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const Key('upgrade_get_artist_pro_button')),
    );
    await tester.tap(find.byKey(const Key('upgrade_get_artist_pro_button')));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentMethodSheet), findsOneWidget);
    expect(repository.getPlansCalls, 0);

    await tester.tap(find.byKey(const Key('payment_method_option_paypal')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('payment_continue_button')));
    await tester.pumpAndSettle();
    expect(repository.subscribeCalls, 1);
    expect(repository.lastBillingCycle, BillingCycle.monthly);

    Navigator.of(tester.element(find.byType(PaymentMethodSheet))).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('upgrade_see_all_plans_button')),
    );
    await tester.tap(find.byKey(const Key('upgrade_see_all_plans_button')));
    await tester.pumpAndSettle();
    expect(find.byType(SubscriptionPlansScreen), findsOneWidget);
  });

  testWidgets('upgrade screen reports unavailable Artist Pro plan', (
    tester,
  ) async {
    useLargeViewport(tester);
    await pumpPremiumScreen(
      tester,
      const UpgradeScreen(popUp: false),
      repository: FakeSubscriptionRepository(plans: [artistPlan()]),
    );
    await tester.pump();

    await tester.ensureVisible(
      find.byKey(const Key('upgrade_get_artist_pro_button')),
    );
    await tester.tap(find.byKey(const Key('upgrade_get_artist_pro_button')));
    await tester.pumpAndSettle();

    expect(find.text('Artist Pro unavailable'), findsOneWidget);
    await tester.tap(find.byKey(const Key('artist_pro_unavailable_ok_button')));
    await tester.pumpAndSettle();
    expect(find.text('Artist Pro unavailable'), findsNothing);
  });

  testWidgets('subscription plans screen loads cards and page indicator', (
    tester,
  ) async {
    useLargeViewport(tester);
    await pumpPremiumScreen(
      tester,
      const SubscriptionPlansScreen(),
      initialState: SubscriptionState(
        currentSubscription: activeArtistProSubscription(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('subscription_plans_screen')), findsOneWidget);
    expect(find.byKey(const Key('subscription_plan_content')), findsOneWidget);
    expect(
      find.byKey(const Key('subscription_plans_page_view')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('subscription_plan_page_indicator')),
      findsOneWidget,
    );
    final content = tester.widget<SubscriptionPlanContent>(
      find.byKey(const Key('subscription_plan_content')),
    );
    content.onPageChanged(1);
    await tester.pump();
    expect(
      await content.onSubscribe(
        artistPlan(),
        BillingCycle.yearly,
        cardPaymentMethod,
      ),
      'Subscription activated',
    );
    await tester.ensureVisible(
      find.byKey(const Key('subscription_testimonial')),
    );
    expect(find.byKey(const Key('subscription_testimonial')), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('subscription_faq_section')),
    );
    expect(find.byKey(const Key('subscription_faq_section')), findsOneWidget);
  });

  testWidgets('subscription plans screen can retry after plan error', (
    tester,
  ) async {
    useLargeViewport(tester);
    final repository = FakeSubscriptionRepository(
      plansError: Exception('network'),
    );

    await pumpPremiumScreen(
      tester,
      const SubscriptionPlansScreen(),
      repository: repository,
      initialState: SubscriptionState(
        currentSubscription: activeArtistProSubscription(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('subscription_plans_error_retry')),
      findsOneWidget,
    );

    repository.plansError = null;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('subscription_plans_page_view')),
      findsOneWidget,
    );
  });

  testWidgets(
    'current subscription screen shows billing features and actions',
    (tester) async {
      useLargeViewport(tester);
      final repository = FakeSubscriptionRepository(
        currentSubscription: activeArtistProSubscription(),
      );

      await pumpPremiumScreen(
        tester,
        const CurrentSubscriptionScreen(),
        repository: repository,
        initialState: SubscriptionState(
          currentSubscription: activeArtistProSubscription(),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('current_subscription_screen')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('current_subscription_plan_name')),
        findsOneWidget,
      );
      expect(find.text('Artist Pro'), findsOneWidget);
      expect(find.text('Renews May 15, 2026'), findsOneWidget);
      expect(find.text('Unlimited uploads'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('current_subscription_see_more_plans_button')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SubscriptionPlansScreen), findsOneWidget);
    },
  );

  testWidgets('current subscription cancel button calls notifier', (
    tester,
  ) async {
    useLargeViewport(tester);
    final repository = FakeSubscriptionRepository(
      currentSubscription: activeArtistProSubscription(),
    );

    await pumpPremiumScreen(
      tester,
      const CurrentSubscriptionScreen(),
      repository: repository,
      initialState: SubscriptionState(
        currentSubscription: activeArtistProSubscription(),
        selectedBillingCycle: BillingCycle.yearly,
      ),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('current_subscription_cancel_button')),
    );
    await tester.pumpAndSettle();

    expect(repository.cancelCalls, 1);
  });

  testWidgets('current subscription labels non-renewing free state', (
    tester,
  ) async {
    useLargeViewport(tester);
    await pumpPremiumScreen(
      tester,
      const CurrentSubscriptionScreen(),
      initialState: SubscriptionState(
        currentSubscription: freeSubscription().copyWith(
          tier: SubscriptionTier.free,
          autoRenew: false,
        ),
      ),
    );

    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Active until: Not scheduled'), findsOneWidget);
  });
}
