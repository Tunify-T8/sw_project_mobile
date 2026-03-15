import 'package:flutter/material.dart';

class TrackMetadataTabSwitcher extends StatelessWidget {
  const TrackMetadataTabSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: const [
          _ActiveTabLabel(label: 'Track Info'),
          _InactiveTabLabel(label: 'Advanced'),
          _InactiveTabLabel(label: 'Permissions'),
        ],
      ),
    );
  }
}

class _ActiveTabLabel extends StatelessWidget {
  final String label;

  const _ActiveTabLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white54),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InactiveTabLabel extends StatelessWidget {
  final String label;

  const _InactiveTabLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}