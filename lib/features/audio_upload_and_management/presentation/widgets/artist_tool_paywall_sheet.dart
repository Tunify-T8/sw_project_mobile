import 'package:flutter/material.dart';

enum ArtistToolKind {
  amplify,
  uploadTime,
  replaceFile,
}

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
    builder: (_) {
      return _ArtistToolPaywallSheet(
        kind: kind,
        onSubscribe: onSubscribe,
        uploadMinutesRemaining: uploadMinutesRemaining,
        uploadMinutesLimit: uploadMinutesLimit,
      );
    },
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
    final data = _sheetData(kind);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F10),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
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
                  Icon(
                    data.icon,
                    color: data.iconColor,
                    size: 26,
                  ),
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
              if (kind == ArtistToolKind.uploadTime)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2C),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'As a free user, you can upload up to '
                    '${uploadMinutesLimit ?? 180 ~/ 60} hours of audio content.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      height: 1.35,
                    ),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.body,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      height: 1.5,
                    ),
                  ),
                ),
              if (kind == ArtistToolKind.uploadTime) ...[
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Upgrade to Artist Pro to get unlimited uploads.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1.35,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.subBody ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  const TextSpan(
                    children: [
                      TextSpan(
                        text: 'EGP 164.99/month. ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: 'Cancel anytime. ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: 'Restrictions apply.',
                        style: TextStyle(
                          color: Color(0xFF6AA8FF),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSubscribe?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Subscribe now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Maybe later',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ArtistToolSheetData _sheetData(ArtistToolKind kind) {
    switch (kind) {
      case ArtistToolKind.amplify:
        return const _ArtistToolSheetData(
          eyebrow: 'AMPLIFY',
          title: 'Reach more listeners.',
          body:
              'With Artist Pro, you can get your tracks analyzed and recommended to the right listeners without limits.',
          icon: Icons.bolt_rounded,
          iconColor: Color(0xFFB873FF),
        );
      case ArtistToolKind.uploadTime:
        return _ArtistToolSheetData(
          eyebrow: 'UPLOAD',
          title: 'You have limited\nupload time',
          body: '',
          icon: Icons.cloud_upload_outlined,
          iconColor: const Color(0xFF7CB4FF),
          subBody: uploadMinutesRemaining != null && uploadMinutesLimit != null
              ? '$uploadMinutesRemaining/$uploadMinutesLimit mins remaining'
              : null,
        );
      case ArtistToolKind.replaceFile:
        return const _ArtistToolSheetData(
          eyebrow: 'REPLACE FILE',
          title: 'Enjoy unlimited file\nreplacements.',
          body:
              'With Artist Pro, you can replace files without limits.',
          icon: Icons.swap_horiz_rounded,
          iconColor: Color(0xFF7CB4FF),
        );
    }
  }
}

class _ArtistToolSheetData {
  final String eyebrow;
  final String title;
  final String body;
  final String? subBody;
  final IconData icon;
  final Color iconColor;

  const _ArtistToolSheetData({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
    this.subBody,
  });
}