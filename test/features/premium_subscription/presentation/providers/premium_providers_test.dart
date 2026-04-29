import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:software_project/core/network/dio_client.dart';
import 'package:software_project/features/premium_subscription/data/repository/subscription_repository_impl.dart';
import 'package:software_project/features/premium_subscription/domain/entities/billing_cycle.dart';
import 'package:software_project/features/premium_subscription/domain/entities/payment_method_type.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_tier.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/payment_sheet_notifier.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/payment_sheet_state.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/subscription_notifier.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/subscription_provider.dart';
import 'package:software_project/features/premium_subscription/presentation/providers/subscription_state.dart';

import '../../helpers/premium_test_data.dart';

void main() {
  group('PaymentSheetState and notifier', () {
    test('state copyWith clears nullable messages unless supplied', () {
      const state = PaymentSheetState(
        selectedMethod: PaymentMethodType.paypal,
        isProcessing: true,
        isSuccessful: true,
        resultMessage: 'ok',
        errorMessage: 'bad',
      );

      final copied = state.copyWith(
        selectedMethod: PaymentMethodType.apple,
        isProcessing: false,
      );

      expect(copied.selectedMethod, PaymentMethodType.apple);
      expect(copied.isProcessing, isFalse);
      expect(copied.isSuccessful, isTrue);
      expect(copied.resultMessage, isNull);
      expect(copied.errorMessage, isNull);
    });

    test(
      'notifier transitions through method, processing, success and reset',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(paymentSheetNotifierProvider.notifier);

        notifier.selectMethod(PaymentMethodType.paypal);
        expect(
          container.read(paymentSheetNotifierProvider).selectedMethod,
          PaymentMethodType.paypal,
        );

        notifier.processPayment();
        expect(
          container.read(paymentSheetNotifierProvider).isProcessing,
          isTrue,
        );
        expect(
          container.read(paymentSheetNotifierProvider).isSuccessful,
          isFalse,
        );

        notifier.paymentSuccess('done');
        expect(
          container.read(paymentSheetNotifierProvider).isProcessing,
          isFalse,
        );
        expect(
          container.read(paymentSheetNotifierProvider).isSuccessful,
          isTrue,
        );
        expect(
          container.read(paymentSheetNotifierProvider).resultMessage,
          'done',
        );

        notifier.reset();
        expect(
          container.read(paymentSheetNotifierProvider).selectedMethod,
          PaymentMethodType.card,
        );
        expect(
          container.read(paymentSheetNotifierProvider).resultMessage,
          isNull,
        );
      },
    );

    test('notifier records payment failure', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(paymentSheetNotifierProvider.notifier)
          .paymentFailed('declined');

      final state = container.read(paymentSheetNotifierProvider);
      expect(state.isProcessing, isFalse);
      expect(state.isSuccessful, isFalse);
      expect(state.errorMessage, 'declined');
      expect(state.resultMessage, isNull);
    });
  });

  group('SubscriptionState and notifier', () {
    test('repository provider builds the real repository implementation', () {
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(Dio())],
      );
      addTearDown(container.dispose);

      final repository = container.read(subscriptionRepositoryProvider);

      expect(repository, isA<SubscriptionRepositoryImpl>());
    });

    test('state copyWith updates values and clears nullable messages', () {
      final state = SubscriptionState(
        plans: [artistPlan()],
        currentSubscription: activeArtistProSubscription(),
        isPlansLoading: true,
        isCurrentLoading: true,
        isSubscribing: true,
        isCancelling: true,
        hasLoadedPlans: true,
        hasLoadedCurrent: true,
        selectedBillingCycle: BillingCycle.yearly,
        plansError: 'plans',
        currentError: 'current',
        actionError: 'action',
        actionMessage: 'message',
      );

      final copied = state.copyWith(
        plans: [artistProPlan()],
        isPlansLoading: false,
        selectedBillingCycle: BillingCycle.monthly,
      );

      expect(copied.plans.single.tier, SubscriptionTier.artistpro);
      expect(copied.currentSubscription.tier, SubscriptionTier.artistpro);
      expect(copied.isPlansLoading, isFalse);
      expect(copied.isCurrentLoading, isTrue);
      expect(copied.isSubscribing, isTrue);
      expect(copied.isCancelling, isTrue);
      expect(copied.hasLoadedPlans, isTrue);
      expect(copied.hasLoadedCurrent, isTrue);
      expect(copied.selectedBillingCycle, BillingCycle.monthly);
      expect(copied.plansError, isNull);
      expect(copied.currentError, isNull);
      expect(copied.actionError, isNull);
      expect(copied.actionMessage, isNull);
    });

    test('loads plans and current subscription successfully', () async {
      final repository = FakeSubscriptionRepository(
        currentSubscription: activeArtistProSubscription(),
      );
      final container = ProviderContainer(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(subscriptionNotifierProvider.notifier);

      await notifier.loadPlans();
      await notifier.loadCurrentSubscription();

      final state = container.read(subscriptionNotifierProvider);
      expect(state.plans, repository.plans);
      expect(state.hasLoadedPlans, isTrue);
      expect(state.isPlansLoading, isFalse);
      expect(state.currentSubscription.tier, SubscriptionTier.artistpro);
      expect(state.hasLoadedCurrent, isTrue);
      expect(state.isCurrentLoading, isFalse);
    });

    test('records load errors', () async {
      final repository = FakeSubscriptionRepository(
        plansError: Exception('plans failed'),
        currentError: Exception('current failed'),
      );
      final container = ProviderContainer(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(subscriptionNotifierProvider.notifier);

      await notifier.loadPlans();
      var state = container.read(subscriptionNotifierProvider);
      expect(state.hasLoadedPlans, isTrue);
      expect(state.plansError, contains('plans failed'));

      await notifier.loadCurrentSubscription();
      state = container.read(subscriptionNotifierProvider);
      expect(state.hasLoadedCurrent, isTrue);
      expect(state.currentError, contains('current failed'));
    });

    test(
      'subscribe uses selected billing cycle and refreshes current',
      () async {
        final repository = FakeSubscriptionRepository();
        final container = ProviderContainer(
          overrides: [
            subscriptionRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(subscriptionNotifierProvider.notifier);

        notifier.setBillingCycle(BillingCycle.yearly);
        final message = await notifier.subscribe(
          tier: SubscriptionTier.artistpro,
          paymentMethod: cardPaymentMethod,
          trialDays: 5,
        );

        final state = container.read(subscriptionNotifierProvider);
        expect(message, 'Subscription activated');
        expect(repository.lastBillingCycle, BillingCycle.yearly);
        expect(repository.lastTrialDays, 5);
        expect(state.isSubscribing, isFalse);
        expect(state.currentSubscription.tier, SubscriptionTier.artistpro);
        expect(repository.getCurrentCalls, 1);
      },
    );

    test('subscribe stores error and rethrows exception', () async {
      final repository = FakeSubscriptionRepository(
        subscribeError: Exception('card declined'),
      );
      final container = ProviderContainer(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(subscriptionNotifierProvider.notifier);

      await expectLater(
        notifier.subscribe(
          tier: SubscriptionTier.artist,
          paymentMethod: cardPaymentMethod,
        ),
        throwsA(isA<Exception>()),
      );

      final state = container.read(subscriptionNotifierProvider);
      expect(state.isSubscribing, isFalse);
      expect(state.actionError, contains('card declined'));
    });

    test('cancel subscription handles success and error paths', () async {
      final repository = FakeSubscriptionRepository(
        currentSubscription: activeArtistProSubscription(),
      );
      final container = ProviderContainer(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(subscriptionNotifierProvider.notifier);

      await notifier.cancelSubscription();

      var state = container.read(subscriptionNotifierProvider);
      expect(state.isCancelling, isFalse);
      expect(state.currentSubscription.tier, SubscriptionTier.free);
      expect(repository.cancelCalls, 1);

      repository.cancelError = Exception('cancel failed');
      await notifier.cancelSubscription();

      state = container.read(subscriptionNotifierProvider);
      expect(state.isCancelling, isFalse);
      expect(state.actionError, contains('cancel failed'));

      notifier.clearActionMessage();
      state = container.read(subscriptionNotifierProvider);
      expect(state.actionError, isNull);
      expect(state.actionMessage, isNull);
    });
  });
}
