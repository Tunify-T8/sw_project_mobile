import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/premium_subscription/domain/entities/billing_cycle.dart';
import 'package:software_project/features/premium_subscription/domain/entities/payment_method_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_tier.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/subscription_provider.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/subscription_notifier.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/subscription_state.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/faq_section.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/payment/payment_method_sheet.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/subscription_card.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/subscription_plan_content.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/subscription_restrictions_link.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/subscription_testimonial.dart';
import 'package:software_project/features/premium_subscription/presentation/widgets/upgrade_image.dart';

import '../../../../test_utils/mock_network_images.dart';
import '../../helpers/premium_test_data.dart';

class InitialSubscriptionNotifier extends SubscriptionNotifier {
  InitialSubscriptionNotifier(this.initial);

  final SubscriptionState initial;

  @override
  SubscriptionState build() => initial;
}

Future<void> pumpPremiumWidget(
  WidgetTester tester,
  Widget child, {
  FakeSubscriptionRepository? repository,
  SubscriptionState? initialState,
}) {
  return mockNetworkImagesFor(() {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(
            repository ?? FakeSubscriptionRepository(),
          ),
          if (initialState != null)
            subscriptionNotifierProvider.overrideWith(
              () => InitialSubscriptionNotifier(initialState),
            ),
        ],
        child: MaterialApp(
          home: Scaffold(backgroundColor: Colors.black, body: child),
        ),
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

  testWidgets('FAQ expands both questions', (tester) async {
    await pumpPremiumWidget(tester, const FaqSection());

    await tester.tap(find.byKey(const Key('subscription_faq_fan_artist_tile')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Fan-oriented plans'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('subscription_faq_annual_family_tile')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('annual or family plan'), findsOneWidget);
  });

  testWidgets('restrictions link opens sheet with terms and privacy buttons', (
    tester,
  ) async {
    await pumpPremiumWidget(
      tester,
      const SubscriptionRestrictionsLink(
        subscriptionPlan: SubscriptionTier.artistpro,
      ),
    );

    await tester.tap(
      find.byKey(const Key('subscription_restrictions_link_artistpro')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('subscription_restrictions_sheet_artistpro')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('subscription_restrictions_terms_artistpro')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('subscription_restrictions_privacy_artistpro')),
      findsOneWidget,
    );
  });

  testWidgets('upgrade image and testimonial render their primary surfaces', (
    tester,
  ) async {
    await pumpPremiumWidget(
      tester,
      const SingleChildScrollView(
        child: Column(
          children: [
            UpgradeImage(key: Key('upgrade_image_test')),
            SubscriptionTestimonial(key: Key('testimonial_test')),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('upgrade_image_test')), findsOneWidget);
    expect(find.byKey(const Key('testimonial_test')), findsOneWidget);
  });

  testWidgets('plan content shows loading, error, empty and page states', (
    tester,
  ) async {
    useLargeViewport(tester);
    final controller = PageController();
    addTearDown(controller.dispose);

    Widget content(SubscriptionState state) {
      return SubscriptionPlanContent(
        state: state,
        paidPlans: state.plans
            .where((plan) => plan.tier != SubscriptionTier.free)
            .toList(),
        pageViewController: controller,
        onRetry: () {},
        onPageChanged: (_) {},
        onSubscribe: (_, _, _) async => 'ok',
      );
    }

    await pumpPremiumWidget(
      tester,
      content(SubscriptionState(isPlansLoading: true)),
    );
    expect(find.byKey(const Key('subscription_plans_loading')), findsOneWidget);

    await pumpPremiumWidget(
      tester,
      content(SubscriptionState(plansError: 'bad')),
    );
    expect(
      find.byKey(const Key('subscription_plans_error_retry')),
      findsOneWidget,
    );

    await pumpPremiumWidget(tester, content(SubscriptionState()));
    expect(find.byKey(const Key('subscription_plans_empty')), findsOneWidget);

    await pumpPremiumWidget(
      tester,
      SizedBox(
        width: 700,
        height: 700,
        child: content(SubscriptionState(plans: [artistPlan()])),
      ),
    );
    expect(
      find.byKey(const Key('subscription_plans_page_view')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('subscription_card_artist_monthly')),
      findsOneWidget,
    );

    await pumpPremiumWidget(
      tester,
      SizedBox(
        width: 700,
        height: 700,
        child: SubscriptionPlanContent(
          state: SubscriptionState(plans: [artistPlan(), artistProPlan()]),
          paidPlans: [artistPlan(), artistProPlan()],
          pageViewController: controller,
          onRetry: () {},
          onPageChanged: (_) {},
          onSubscribe: (plan, billingCycle, paymentMethod) async {
            return '${plan.tier.name}-${billingCycle.name}-${paymentMethod.type.name}';
          },
        ),
      ),
    );
    final monthlyCard = tester.widget<SubscriptionCard>(
      find.byKey(const Key('subscription_card_artist_monthly')),
    );
    expect(
      await monthlyCard.onSubscribe(cardPaymentMethod),
      'artist-monthly-card',
    );

    controller.jumpToPage(1);
    await tester.pumpAndSettle();
    final yearlyCard = tester.widget<SubscriptionCard>(
      find.byKey(const Key('subscription_card_artist_yearly')),
    );
    expect(
      await yearlyCard.onSubscribe(cardPaymentMethod),
      'artist-yearly-card',
    );
  });

  testWidgets('subscription card opens payment sheet and forwards payment', (
    tester,
  ) async {
    useLargeViewport(tester);
    PaymentMethodEntity? submitted;

    await pumpPremiumWidget(
      tester,
      SizedBox(
        width: 700,
        height: 700,
        child: SubscriptionCard(
          plan: artistPlan(),
          subscriptionPeriod: BillingCycle.monthly,
          onSubscribe: (method) async {
            submitted = method;
            return 'subscribed';
          },
        ),
      ),
    );

    expect(
      find.byKey(const Key('subscription_subscribe_button_artist_monthly')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('subscription_subscribe_button_artist_monthly')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PaymentMethodSheet), findsOneWidget);

    await tester.tap(find.byKey(const Key('payment_method_option_paypal')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('payment_continue_button')));
    await tester.pumpAndSettle();

    expect(submitted?.type.name, 'paypal');
    expect(find.byKey(const Key('payment_success_result')), findsOneWidget);
  });

  testWidgets('subscription card hides subscribe controls for paid users', (
    tester,
  ) async {
    useLargeViewport(tester);
    await pumpPremiumWidget(
      tester,
      SizedBox(
        width: 700,
        height: 700,
        child: SubscriptionCard(
          plan: artistProPlan(),
          subscriptionPeriod: BillingCycle.yearly,
          onSubscribe: (_) async => 'unused',
        ),
      ),
      repository: FakeSubscriptionRepository(
        currentSubscription: activeArtistProSubscription(),
      ),
      initialState: SubscriptionState(
        currentSubscription: activeArtistProSubscription(),
      ),
    );

    expect(
      find.byKey(const Key('subscription_card_price_artistpro_yearly')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('subscription_subscribe_button_artistpro_yearly')),
      findsNothing,
    );
  });
}
