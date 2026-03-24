// Upload Feature Guide:
// Purpose: Metadata form widget used inside TrackMetadataScreen and TrackMetadataBody.
// Used by: track_metadata_body
// Concerns: Metadata engine; Track visibility.
import 'package:flutter/material.dart';

class PrivacySection extends StatelessWidget {
  final String currentValue;
  final ValueChanged<String> onChanged;

  const PrivacySection({
    super.key,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Privacy',
          style: TextStyle(
            color: Color(0xFFD0D0D0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        _PrivacyOptionTile(
          value: 'public',
          currentValue: currentValue,
          title: 'Public',
          subtitle: 'Anyone can find this',
          onChanged: onChanged,
        ),
        _PrivacyOptionTile(
          value: 'private',
          currentValue: currentValue,
          title: 'Unlisted (Private)',
          subtitle: 'Anyone with private link can access',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PrivacyOptionTile extends StatelessWidget {
  final String value;
  final String currentValue;
  final String title;
  final String subtitle;
  final ValueChanged<String> onChanged;

  const _PrivacyOptionTile({
    required this.value,
    required this.currentValue,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == currentValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF989898),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70, width: 1.5),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
