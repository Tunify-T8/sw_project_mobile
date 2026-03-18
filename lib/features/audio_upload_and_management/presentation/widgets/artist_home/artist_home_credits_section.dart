import 'package:flutter/material.dart';

import '../../../domain/entities/artist_tools_quota.dart';
import '../artist_tool_paywall_data.dart';
import '../artist_tool_paywall_sheet.dart';

class ArtistHomeCreditsSection extends StatelessWidget {
  const ArtistHomeCreditsSection({
    super.key,
    required this.quota,
    this.onOpenSubscription,
  });

  final ArtistToolsQuota quota;
  final VoidCallback? onOpenSubscription;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Artist tools',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CreditCard(
                  icon: Icons.bolt_rounded,
                  iconColor: const Color(0xFFB873FF),
                  label: 'Amplify',
                  subText: quota.canAmplify ? 'OPEN' : 'TRY IT',
                  onTap: () => _openPaywall(context, ArtistToolKind.amplify),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CreditCard(
                  icon: Icons.cloud_upload_outlined,
                  iconColor: const Color(0xFF7CB4FF),
                  label: 'Upload time',
                  subText: quota.isFree
                      ? '${quota.uploadMinutesRemaining}/${quota.uploadMinutesLimit} mins left'
                      : 'Unlimited',
                  underlineSubtitle: false,
                  onTap: () => _openPaywall(context, ArtistToolKind.uploadTime),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CreditCard(
                  icon: Icons.swap_horiz_rounded,
                  iconColor: const Color(0xFF7CB4FF),
                  label: 'Replace file',
                  subText: quota.canReplaceFiles ? 'OPEN' : 'TRY IT',
                  onTap: () =>
                      _openPaywall(context, ArtistToolKind.replaceFile),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openPaywall(BuildContext context, ArtistToolKind kind) {
    showArtistToolPaywallSheet(
      context: context,
      kind: kind,
      onSubscribe: onOpenSubscription,
      uploadMinutesRemaining: quota.uploadMinutesRemaining,
      uploadMinutesLimit: quota.uploadMinutesLimit,
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subText,
    required this.onTap,
    this.underlineSubtitle = true,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String subText;
  final VoidCallback onTap;
  final bool underlineSubtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF212124),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 128,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 30),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subText,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  decoration: underlineSubtitle
                      ? TextDecoration.underline
                      : null,
                  decorationColor: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
