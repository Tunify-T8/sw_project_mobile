// Upload Feature Guide:
// Purpose: Metadata form widget used inside TrackMetadataScreen and TrackMetadataBody.
// Used by: permissions_metadata_section
// Concerns: Metadata engine.
import 'package:flutter/material.dart';

const _activeSelectionGreen = Color(0xFF1DB954);

class MetadataPermissionToggleRow extends StatelessWidget {
  const MetadataPermissionToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.locked = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool locked;

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
          IgnorePointer(
            ignoring: locked,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: _activeSelectionGreen,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFF2F2F2F),
            ),
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
    this.disabled = false,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final textColor = disabled ? const Color(0xFF5E5E5E) : Colors.white;
    final borderColor = disabled
        ? (selected ? _activeSelectionGreen : const Color(0xFF3A3A3A))
        : (selected ? _activeSelectionGreen : Colors.white70);
    final fillColor = disabled
        ? (selected ? _activeSelectionGreen : const Color(0xFF2A2A2A))
        : (selected ? _activeSelectionGreen : Colors.transparent);

    return IgnorePointer(
      ignoring: disabled || onTap == null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$title\n$subtitle',
                  style: TextStyle(
                    color: textColor,
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
                  border: Border.all(color: borderColor, width: 1.5),
                  color: fillColor,
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
