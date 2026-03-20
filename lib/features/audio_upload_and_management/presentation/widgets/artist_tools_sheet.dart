import 'package:flutter/material.dart';

import '../../domain/entities/artist_tools_quota.dart';
import 'artist_tool_paywall_data.dart';
import 'artist_tool_paywall_sheet.dart';

Future<void> showArtistToolsSheet({
  required BuildContext context,
  required ArtistToolsQuota quota,
  VoidCallback? onOpenSubscription,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return ArtistToolsSheet(
        quota: quota,
        onOpenSubscription: onOpenSubscription,
      );
    },
  );
}

class ArtistToolsSheet extends StatelessWidget {
  const ArtistToolsSheet({
    super.key,
    required this.quota,
    this.onOpenSubscription,
  });

  final ArtistToolsQuota quota;
  final VoidCallback? onOpenSubscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111113),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Artist Tools',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _ArtistToolCard(
                      icon: Icons.bolt_rounded,
                      iconColor: const Color(0xFFB873FF),
                      title: 'Amplify',
                      subtitle: quota.canAmplify ? 'OPEN' : 'TRY IT',
                      onTap: () =>
                          _openPaywall(context, ArtistToolKind.amplify),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ArtistToolCard(
                      icon: Icons.cloud_upload_outlined,
                      iconColor: const Color(0xFF7CB4FF),
                      title: 'Upload time',
                      subtitle: quota.isFree
                          ? '${quota.uploadMinutesRemaining}/${quota.uploadMinutesLimit} mins left'
                          : 'Unlimited',
                      underlineSubtitle: false,
                      onTap: () =>
                          _openPaywall(context, ArtistToolKind.uploadTime),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ArtistToolCard(
                      icon: Icons.swap_horiz_rounded,
                      iconColor: const Color(0xFF7CB4FF),
                      title: 'Replace file',
                      subtitle: quota.canReplaceFiles ? 'OPEN' : 'TRY IT',
                      onTap: () =>
                          _openPaywall(context, ArtistToolKind.replaceFile),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPaywall(BuildContext context, ArtistToolKind kind) {
    Navigator.of(context).pop();

    showArtistToolPaywallSheet(
      context: context,
      kind: kind,
      onSubscribe: onOpenSubscription,
      uploadMinutesRemaining: quota.uploadMinutesRemaining,
      uploadMinutesLimit: quota.uploadMinutesLimit,
    );
  }
}

class _ArtistToolCard extends StatelessWidget {
  const _ArtistToolCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.underlineSubtitle = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
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
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
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
