import 'package:flutter/material.dart';

const _activeSelectionGreen = Color(0xFF1DB954);

class MetadataPermissionToggleRow extends StatelessWidget {
  const MetadataPermissionToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '$title\n$subtitle',
              style: const TextStyle(
                color: Colors.white,
                height: 1.45,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _activeSelectionGreen,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF2F2F2F),
          ),
        ],
      ),
    );
  }
}

class MetadataPermissionRadioRow extends StatelessWidget {
  const MetadataPermissionRadioRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '$title\n$subtitle',
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.45,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _activeSelectionGreen : Colors.white70,
                  width: 1.5,
                ),
                color: selected ? _activeSelectionGreen : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
