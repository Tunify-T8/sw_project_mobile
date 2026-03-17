import 'package:flutter/material.dart';

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
      onSubscribe: onSubscribe,
      uploadMinutesRemaining: uploadMinutesRemaining,
      uploadMinutesLimit: uploadMinutesLimit,
    ),
  );
}

class _ArtistToolPaywallSheet extends StatelessWidget {
  const _ArtistToolPaywallSheet({
    required this.kind,
    required this.onSubscribe,
    required this.uploadMinutesRemaining,
    required this.uploadMinutesLimit,
  });

  final ArtistToolKind kind;
  final VoidCallback? onSubscribe;
  final int? uploadMinutesRemaining;
  final int? uploadMinutesLimit;

  @override
  Widget build(BuildContext context) {
    final data = artistToolSheetData(
      kind,
      uploadMinutesRemaining: uploadMinutesRemaining,
      uploadMinutesLimit: uploadMinutesLimit,
    );

    return Container(
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
                kind: kind,
                data: data,
                uploadMinutesLimit: uploadMinutesLimit,
              ),
              const SizedBox(height: 28),
              ArtistToolPaywallFooter(
                onSubscribe: () {
                  Navigator.of(context).pop();
                  onSubscribe?.call();
                },
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
              'As a free user, you can upload up to ${uploadMinutesLimit ?? 180 ~/ 60} hours of audio content.',
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
