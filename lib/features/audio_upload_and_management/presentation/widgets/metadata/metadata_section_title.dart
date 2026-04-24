// Upload Feature Guide:
// Purpose: Metadata form widget used inside TrackMetadataScreen and TrackMetadataBody.
// Used by: advanced_metadata_section, permissions_metadata_section, track_info_form_section
// Concerns: Metadata engine.
import 'package:flutter/material.dart';

class MetadataSectionTitle extends StatelessWidget {
  const MetadataSectionTitle(this.title, {super.key, this.requiredField = false});

  final String title;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: Color(0xFFD0D0D0),
      fontSize: 17,
      fontWeight: FontWeight.w500,
    );

    if (!requiredField) {
      return Text(title, style: labelStyle);
    }

    return RichText(
      text: TextSpan(
        style: labelStyle,
        children: [
          TextSpan(text: title),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
