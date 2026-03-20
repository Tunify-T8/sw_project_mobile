import 'package:flutter/material.dart';

class MetadataLabelWithInfo extends StatelessWidget {
  const MetadataLabelWithInfo(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD0D0D0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.info_outline, size: 18, color: Colors.white70),
      ],
    );
  }
}
