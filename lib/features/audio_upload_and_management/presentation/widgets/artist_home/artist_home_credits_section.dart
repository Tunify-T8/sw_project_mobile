import 'package:flutter/material.dart';

class ArtistHomeCreditsSection extends StatelessWidget {
  const ArtistHomeCreditsSection({
    super.key,
    required this.remainingMinutes,
    required this.totalMinutes,
  });

  final int remainingMinutes;
  final int totalMinutes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your remaining credits',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: _CreditCard(
                  icon: Icons.bolt,
                  iconColor: Color(0xFFBB86FC),
                  label: 'Amplify',
                  subText: 'TRY IT',
                  isLink: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CreditCard(
                  icon: Icons.cloud_upload,
                  iconColor: const Color(0xFF4FC3F7),
                  label: 'Upload time',
                  subText: '$remainingMinutes/$totalMinutes mins left',
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _CreditCard(
                  icon: Icons.swap_horiz,
                  iconColor: Color(0xFF4FC3F7),
                  label: 'Replace file',
                  subText: 'TRY IT',
                  isLink: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subText,
    this.isLink = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String subText;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              decoration: isLink ? TextDecoration.underline : null,
              decorationColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
