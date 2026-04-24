// Upload Feature Guide:
// Purpose: Metadata form widget used inside TrackMetadataScreen and TrackMetadataBody.
// Used by: advanced_metadata_section, permissions_metadata_section, track_info_form_section
// Concerns: Metadata engine.
import 'package:flutter/material.dart';

InputDecoration buildMetadataInputDecoration(
  String label, {
  String? hintText,
  bool requiredField = false,
}) {
  const labelStyle = TextStyle(
    color: Color(0xFFD0D0D0),
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );

  final Widget? customLabel = requiredField
      ? RichText(
          text: TextSpan(
            style: labelStyle,
            children: [
              TextSpan(text: label),
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        )
      : null;

  return InputDecoration(
    label: customLabel,
    labelText: customLabel == null ? label : null,
    hintText: hintText,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: labelStyle,
    hintStyle: const TextStyle(
      color: Color(0xFF666666),
      fontSize: 17,
      fontWeight: FontWeight.w400,
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF464646), width: 1),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF7A7A7A), width: 1),
    ),
    contentPadding: const EdgeInsets.only(top: 6, bottom: 12),
    isDense: true,
  );
}
