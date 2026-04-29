import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/premium_subscription/domain/entities/billing_cycle.dart';
import 'package:software_project/features/premium_subscription/domain/entities/current_subscription_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/payment_method_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/payment_method_type.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_features_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_plan_entity.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_status.dart';
import 'package:software_project/features/premium_subscription/domain/entities/subscription_tier.dart';

void main() {
  group('CurrentSubscriptionEntity', () {
    test('constructor stores all fields, including nullable dates', () {
      final startedAt = DateTime(2026, 1, 1);
      final expiresAt = DateTime(2026, 2, 1);
      const features = SubscriptionFeaturesEntity(
        uploadLimit: 360,
        adFree: true,
        offlineListening: true,
        limitPlaybackAccess: true,
        playlistLimit: 10,
      );

      final entity = CurrentSubscriptionEntity(
        tier: SubscriptionTier.artist,
        status: SubscriptionStatus.trial,
        startedAt: startedAt,
        expiresAt: expiresAt,
        autoRenew: false,
        features: features,
      );

      expect(entity.tier, SubscriptionTier.artist);
      expect(entity.status, SubscriptionStatus.trial);
      expect(entity.startedAt, startedAt);
      expect(entity.expiresAt, expiresAt);
      expect(entity.autoRenew, isFalse);
      expect(entity.features, same(features));
    });

    test('default constructor describes a free active subscription', () {
      const entity = CurrentSubscriptionEntity();

      expect(entity.tier, SubscriptionTier.free);
      expect(entity.status, SubscriptionStatus.active);
      expect(entity.startedAt, isNull);
      expect(entity.expiresAt, isNull);
      expect(entity.autoRenew, isTrue);
      expect(entity.features.uploadLimit, 180);
    });

    test('copyWith with no parameters preserves every field', () {
      final startedAt = DateTime(2026, 3, 1);
      final expiresAt = DateTime(2026, 4, 1);
      const features = SubscriptionFeaturesEntity(uploadLimit: 720);
      final original = CurrentSubscriptionEntity(
        tier: SubscriptionTier.artistpro,
        status: SubscriptionStatus.cancelled,
        startedAt: startedAt,
        expiresAt: expiresAt,
        autoRenew: false,
        features: features,
      );

      final copied = original.copyWith();

      expect(copied, isNot(same(original)));
      expect(copied.tier, original.tier);
      expect(copied.status, original.status);
      expect(copied.startedAt, original.startedAt);
      expect(copied.expiresAt, original.expiresAt);
      expect(copied.autoRenew, original.autoRenew);
      expect(copied.features, same(features));
    });

    test('copyWith can update one field and preserve nullable dates', () {
      final startedAt = DateTime(2026, 5, 1);
      final expiresAt = DateTime(2026, 6, 1);
      final original = CurrentSubscriptionEntity(
        tier: SubscriptionTier.artist,
        status: SubscriptionStatus.active,
        startedAt: startedAt,
        expiresAt: expiresAt,
        autoRenew: true,
        features: const SubscriptionFeaturesEntity(uploadLimit: 360),
      );

      final copied = original.copyWith(status: SubscriptionStatus.expired);

      expect(copied.tier, SubscriptionTier.artist);
      expect(copied.status, SubscriptionStatus.expired);
      expect(copied.startedAt, startedAt);
      expect(copied.expiresAt, expiresAt);
      expect(copied.autoRenew, isTrue);
      expect(copied.features.uploadLimit, 360);
    });

    test('copyWith can update multiple fields including nested features', () {
      final startedAt = DateTime(2026, 7, 1);
      final expiresAt = DateTime(2026, 8, 1);
      const replacementFeatures = SubscriptionFeaturesEntity(
        uploadLimit: -1,
        adFree: true,
        offlineListening: true,
        limitPlaybackAccess: true,
        playlistLimit: -1,
      );

      final copied = const CurrentSubscriptionEntity().copyWith(
        tier: SubscriptionTier.artistpro,
        status: SubscriptionStatus.trial,
        startedAt: startedAt,
        expiresAt: expiresAt,
        autoRenew: false,
        features: replacementFeatures,
      );

      expect(copied.tier, SubscriptionTier.artistpro);
      expect(copied.status, SubscriptionStatus.trial);
      expect(copied.startedAt, startedAt);
      expect(copied.expiresAt, expiresAt);
      expect(copied.autoRenew, isFalse);
      expect(copied.features, same(replacementFeatures));
    });

    test('does not implement value equality', () {
      final first = CurrentSubscriptionEntity();
      final second = CurrentSubscriptionEntity();

      expect(first == second, isFalse);
    });
  });

  group('SubscriptionFeaturesEntity', () {
    test('constructor stores all fields', () {
      const entity = SubscriptionFeaturesEntity(
        uploadLimit: -1,
        adFree: true,
        offlineListening: true,
        limitPlaybackAccess: true,
        playlistLimit: 99,
      );

      expect(entity.uploadLimit, -1);
      expect(entity.adFree, isTrue);
      expect(entity.offlineListening, isTrue);
      expect(entity.limitPlaybackAccess, isTrue);
      expect(entity.playlistLimit, 99);
    });

    test('default constructor stores free feature limits', () {
      const entity = SubscriptionFeaturesEntity();

      expect(entity.uploadLimit, 180);
      expect(entity.adFree, isFalse);
      expect(entity.offlineListening, isFalse);
      expect(entity.limitPlaybackAccess, isFalse);
      expect(entity.playlistLimit, 3);
    });

    test('copyWith with no parameters preserves every field', () {
      const original = SubscriptionFeaturesEntity(
        uploadLimit: 360,
        adFree: true,
        offlineListening: true,
        limitPlaybackAccess: false,
        playlistLimit: 20,
      );

      final copied = original.copyWith();

      expect(copied, isNot(same(original)));
      expect(copied.uploadLimit, 360);
      expect(copied.adFree, isTrue);
      expect(copied.offlineListening, isTrue);
      expect(copied.limitPlaybackAccess, isFalse);
      expect(copied.playlistLimit, 20);
    });

    test('copyWith can update one field', () {
      const original = SubscriptionFeaturesEntity(
        uploadLimit: 360,
        adFree: false,
        offlineListening: false,
        limitPlaybackAccess: false,
        playlistLimit: 20,
      );

      final copied = original.copyWith(offlineListening: true);

      expect(copied.uploadLimit, 360);
      expect(copied.adFree, isFalse);
      expect(copied.offlineListening, isTrue);
      expect(copied.limitPlaybackAccess, isFalse);
      expect(copied.playlistLimit, 20);
    });

    test('copyWith can update multiple fields', () {
      final copied = const SubscriptionFeaturesEntity().copyWith(
        uploadLimit: -1,
        adFree: true,
        offlineListening: true,
        limitPlaybackAccess: true,
        playlistLimit: -1,
      );

      expect(copied.uploadLimit, -1);
      expect(copied.adFree, isTrue);
      expect(copied.offlineListening, isTrue);
      expect(copied.limitPlaybackAccess, isTrue);
      expect(copied.playlistLimit, -1);
    });

    test('does not implement value equality', () {
      final first = SubscriptionFeaturesEntity();
      final second = SubscriptionFeaturesEntity();

      expect(first == second, isFalse);
    });
  });

  group('SubscriptionPlanEntity', () {
    test('constructor stores all fields including nested features', () {
      const features = SubscriptionFeaturesEntity(
        uploadLimit: -1,
        adFree: true,
        offlineListening: true,
        limitPlaybackAccess: true,
        playlistLimit: -1,
      );
      final entity = SubscriptionPlanEntity(
        tier: SubscriptionTier.artistpro,
        monthlyPrice: 175,
        yearlyPrice: 1750,
        currency: 'EGP',
        features: features,
      );

      expect(entity.tier, SubscriptionTier.artistpro);
      expect(entity.monthlyPrice, 175);
      expect(entity.yearlyPrice, 1750);
      expect(entity.currency, 'EGP');
      expect(entity.features, same(features));
      expect(entity.features.offlineListening, isTrue);
    });

    test('copyWith with no parameters preserves every field', () {
      const features = SubscriptionFeaturesEntity(uploadLimit: 360);
      final original = SubscriptionPlanEntity(
        tier: SubscriptionTier.artist,
        monthlyPrice: 99,
        yearlyPrice: 990,
        currency: 'EGP',
        features: features,
      );

      final copied = original.copyWith();

      expect(copied, isNot(same(original)));
      expect(copied.tier, SubscriptionTier.artist);
      expect(copied.monthlyPrice, 99);
      expect(copied.yearlyPrice, 990);
      expect(copied.currency, 'EGP');
      expect(copied.features, same(features));
    });

    test('copyWith can update one field and preserve nested features', () {
      const features = SubscriptionFeaturesEntity(uploadLimit: 360);
      final original = SubscriptionPlanEntity(
        tier: SubscriptionTier.artist,
        monthlyPrice: 99,
        yearlyPrice: 990,
        currency: 'EGP',
        features: features,
      );

      final copied = original.copyWith(monthlyPrice: 120);

      expect(copied.tier, SubscriptionTier.artist);
      expect(copied.monthlyPrice, 120);
      expect(copied.yearlyPrice, 990);
      expect(copied.currency, 'EGP');
      expect(copied.features, same(features));
    });

    test('copyWith can update multiple fields including nested features', () {
      const replacementFeatures = SubscriptionFeaturesEntity(
        uploadLimit: -1,
        adFree: true,
        offlineListening: true,
        limitPlaybackAccess: true,
        playlistLimit: -1,
      );
      final original = SubscriptionPlanEntity(
        tier: SubscriptionTier.free,
        monthlyPrice: 0,
        yearlyPrice: 0,
        currency: 'USD',
        features: const SubscriptionFeaturesEntity(),
      );

      final copied = original.copyWith(
        tier: SubscriptionTier.artistpro,
        monthlyPrice: 175,
        yearlyPrice: 1750,
        currency: 'EGP',
        features: replacementFeatures,
      );

      expect(copied.tier, SubscriptionTier.artistpro);
      expect(copied.monthlyPrice, 175);
      expect(copied.yearlyPrice, 1750);
      expect(copied.currency, 'EGP');
      expect(copied.features, same(replacementFeatures));
    });

    test('does not implement value equality', () {
      final first = SubscriptionPlanEntity(
        tier: SubscriptionTier.free,
        monthlyPrice: 0,
        yearlyPrice: 0,
        currency: 'EGP',
        features: const SubscriptionFeaturesEntity(),
      );
      final second = SubscriptionPlanEntity(
        tier: SubscriptionTier.free,
        monthlyPrice: 0,
        yearlyPrice: 0,
        currency: 'EGP',
        features: const SubscriptionFeaturesEntity(),
      );

      expect(first == second, isFalse);
    });
  });

  test('entity defaults describe a free active subscription', () {
    const current = CurrentSubscriptionEntity();
    const features = SubscriptionFeaturesEntity();

    expect(current.tier, SubscriptionTier.free);
    expect(current.status, SubscriptionStatus.active);
    expect(current.autoRenew, isTrue);
    expect(features.uploadLimit, 180);
    expect(features.playlistLimit, 3);
    expect(features.adFree, isFalse);
    expect(BillingCycle.values, [BillingCycle.monthly, BillingCycle.yearly]);
    expect(PaymentMethodType.values, [
      PaymentMethodType.card,
      PaymentMethodType.paypal,
      PaymentMethodType.apple,
    ]);
  });

  test('copyWith updates only supplied subscription fields', () {
    final original = CurrentSubscriptionEntity(
      tier: SubscriptionTier.artist,
      status: SubscriptionStatus.trial,
      startedAt: DateTime(2026, 1, 1),
      expiresAt: DateTime(2026, 2, 1),
      autoRenew: false,
      features: const SubscriptionFeaturesEntity(uploadLimit: 360),
    );

    final updated = original.copyWith(
      tier: SubscriptionTier.artistpro,
      autoRenew: true,
    );

    expect(updated.tier, SubscriptionTier.artistpro);
    expect(updated.status, SubscriptionStatus.trial);
    expect(updated.startedAt, DateTime(2026, 1, 1));
    expect(updated.expiresAt, DateTime(2026, 2, 1));
    expect(updated.autoRenew, isTrue);
    expect(updated.features.uploadLimit, 360);
  });

  test('feature, plan, and payment copyWith methods keep unchanged values', () {
    const features = SubscriptionFeaturesEntity(
      uploadLimit: 1,
      adFree: false,
      offlineListening: false,
      limitPlaybackAccess: false,
      playlistLimit: 2,
    );
    final plan = SubscriptionPlanEntity(
      tier: SubscriptionTier.artist,
      monthlyPrice: 99,
      yearlyPrice: 999,
      currency: 'EGP',
      features: features,
    );
    const payment = PaymentMethodEntity(type: PaymentMethodType.paypal);

    final copiedFeatures = features.copyWith(adFree: true, playlistLimit: -1);
    final copiedPlan = plan.copyWith(
      tier: SubscriptionTier.artistpro,
      monthlyPrice: 175,
      features: copiedFeatures,
    );
    final copiedPayment = payment.copyWith(
      type: PaymentMethodType.card,
      brand: 'visa',
      last4: '4242',
      expiryMonth: 1,
      expiryYear: 2031,
    );

    expect(copiedFeatures.uploadLimit, 1);
    expect(copiedFeatures.adFree, isTrue);
    expect(copiedFeatures.playlistLimit, -1);
    expect(copiedPlan.tier, SubscriptionTier.artistpro);
    expect(copiedPlan.yearlyPrice, 999);
    expect(copiedPlan.currency, 'EGP');
    expect(copiedPlan.features.adFree, isTrue);
    expect(copiedPayment.type, PaymentMethodType.card);
    expect(copiedPayment.brand, 'visa');
    expect(copiedPayment.last4, '4242');
    expect(copiedPayment.expiryMonth, 1);
    expect(copiedPayment.expiryYear, 2031);
  });

  test('copyWith can replace every optional entity value', () {
    const originalFeatures = SubscriptionFeaturesEntity();
    final originalPlan = SubscriptionPlanEntity(
      tier: SubscriptionTier.free,
      monthlyPrice: 0,
      yearlyPrice: 0,
      currency: 'USD',
      features: originalFeatures,
    );
    final startedAt = DateTime(2026, 3, 1);
    final expiresAt = DateTime(2026, 4, 1);
    const replacementFeatures = SubscriptionFeaturesEntity(
      uploadLimit: -1,
      adFree: true,
      offlineListening: true,
      limitPlaybackAccess: true,
      playlistLimit: -1,
    );

    final current = const CurrentSubscriptionEntity().copyWith(
      tier: SubscriptionTier.artist,
      status: SubscriptionStatus.expired,
      startedAt: startedAt,
      expiresAt: expiresAt,
      autoRenew: false,
      features: replacementFeatures,
    );
    final features = originalFeatures.copyWith(
      uploadLimit: 500,
      adFree: true,
      offlineListening: true,
      limitPlaybackAccess: true,
      playlistLimit: 100,
    );
    final plan = originalPlan.copyWith(
      tier: SubscriptionTier.artistpro,
      monthlyPrice: 175,
      yearlyPrice: 1750,
      currency: 'EGP',
      features: replacementFeatures,
    );
    const originalPayment = PaymentMethodEntity(
      type: PaymentMethodType.paypal,
      last4: '9999',
      brand: 'paypal',
      expiryMonth: 1,
      expiryYear: 2027,
    );
    final payment = originalPayment.copyWith();

    expect(current.tier, SubscriptionTier.artist);
    expect(current.status, SubscriptionStatus.expired);
    expect(current.startedAt, startedAt);
    expect(current.expiresAt, expiresAt);
    expect(current.autoRenew, isFalse);
    expect(current.features.offlineListening, isTrue);
    expect(features.uploadLimit, 500);
    expect(features.adFree, isTrue);
    expect(features.offlineListening, isTrue);
    expect(features.limitPlaybackAccess, isTrue);
    expect(features.playlistLimit, 100);
    expect(plan.tier, SubscriptionTier.artistpro);
    expect(plan.monthlyPrice, 175);
    expect(plan.yearlyPrice, 1750);
    expect(plan.currency, 'EGP');
    expect(plan.features.uploadLimit, -1);
    expect(payment.type, PaymentMethodType.paypal);
    expect(payment.last4, '9999');
    expect(payment.brand, 'paypal');
    expect(payment.expiryMonth, 1);
    expect(payment.expiryYear, 2027);
  });
}
