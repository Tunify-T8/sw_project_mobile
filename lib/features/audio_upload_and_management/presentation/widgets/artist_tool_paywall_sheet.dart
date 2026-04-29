// Upload Feature Guide:
// Purpose: Artist tools/paywall widget used around upload quotas and upgrade prompts.
// Used by: upload_flow_controller, artist_home_credits_section, artist_tools_sheet
// Concerns: Supporting UI and infrastructure for upload and track management.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../premium_subscription/domain/entities/billing_cycle.dart';
import '../../../premium_subscription/domain/entities/subscription_plan_entity.dart';
import '../../../premium_subscription/domain/entities/subscription_tier.dart';
import '../../../premium_subscription/presentation/providers/subscription_notifier.dart';
import '../../../premium_subscription/presentation/widgets/payment/payment_method_sheet.dart';
import 'artist_tool_paywall_data.dart';
import 'artist_tool_paywall_footer.dart';

Future<void> showArtistToolPaywallSheet({
  required BuildContext context,
  required ArtistToolKind kind,
  VoidCallback? onSubscribe,
  int? uploadMinutesRemaining,
  int? uploadMinutesLimit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ArtistToolPaywallSheet(
      kind: kind,
      uploadMinutesRemaining: uploadMinutesRemaining,
      uploadMinutesLimit: uploadMinutesLimit,
    ),
  );
}

class _ArtistToolPaywallSheet extends ConsumerStatefulWidget {
  const _ArtistToolPaywallSheet({
    required this.kind,
    required this.uploadMinutesRemaining,
    required this.uploadMinutesLimit,
  });

  final ArtistToolKind kind;
  final int? uploadMinutesRemaining;
  final int? uploadMinutesLimit;

  @override
  ConsumerState<_ArtistToolPaywallSheet> createState() =>
      _ArtistToolPaywallSheetState();
}

class _ArtistToolPaywallSheetState
    extends ConsumerState<_ArtistToolPaywallSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(subscriptionNotifierProvider);
      if (state.plans.isEmpty && !state.isPlansLoading) {
        ref.read(subscriptionNotifierProvider.notifier).loadPlans();
      }
    });
  }

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
              key: const Key('artist_tool_paywall_unavailable_ok_button'),
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

    final navigator = Navigator.of(context);
    navigator.pop();
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (!navigator.mounted) return;

    showModalBottomSheet(
      context: navigator.context,
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
    final artistProPlan = _findArtistProPlan(subscriptionState.plans);
    final priceText = (artistProPlan == null)
        ? 'EGP 175.00/month.'
        : '${artistProPlan.currency} ${artistProPlan.monthlyPrice.toStringAsFixed(2)}/month.';
    final data = artistToolSheetData(
      widget.kind,
      uploadMinutesRemaining: widget.uploadMinutesRemaining,
      uploadMinutesLimit: widget.uploadMinutesLimit,
    );

    return Container(
      key: Key('artist_tool_paywall_sheet_${widget.kind.name}'),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F10),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Icon(data.icon, color: data.iconColor, size: 26),
                  const SizedBox(width: 8),
                  Text(
                    data.eyebrow,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _ArtistToolPaywallMessage(
                key: Key('artist_tool_paywall_message_${widget.kind.name}'),
                kind: widget.kind,
                data: data,
                uploadMinutesLimit: widget.uploadMinutesLimit,
              ),
              const SizedBox(height: 28),
              ArtistToolPaywallFooter(
                isLoading: subscriptionState.isPlansLoading,
                priceText: priceText,
                onSubscribe: _openArtistProMonthlyPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtistToolPaywallMessage extends StatelessWidget {
  const _ArtistToolPaywallMessage({
    required this.kind,
    required this.data,
    required this.uploadMinutesLimit,
  });

  final ArtistToolKind kind;
  final ArtistToolSheetData data;
  final int? uploadMinutesLimit;

  @override
  Widget build(BuildContext context) {
    if (kind == ArtistToolKind.uploadTime) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2C),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'As a free user, you can upload up to ${uploadMinutesLimit ?? 180 ~/ 60} minutes of audio content.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Upgrade to Artist Pro to get unlimited uploads.',
            style: TextStyle(color: Colors.white, fontSize: 21, height: 1.35),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.body,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 20,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          data.subBody ?? '',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 20,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
