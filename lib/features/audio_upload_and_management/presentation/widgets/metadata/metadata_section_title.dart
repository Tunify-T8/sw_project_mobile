// Upload Feature Guide:
// Purpose: Metadata form widget used inside TrackMetadataScreen and TrackMetadataBody.
// Used by: advanced_metadata_section, permissions_metadata_section, track_info_form_section
// Concerns: Metadata engine.
import 'package:flutter/material.dart';

class MetadataSectionTitle extends StatelessWidget {
  const MetadataSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFD0D0D0),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
