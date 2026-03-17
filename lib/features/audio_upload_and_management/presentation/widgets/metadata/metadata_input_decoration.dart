import 'package:flutter/material.dart';

InputDecoration buildMetadataInputDecoration(String label, {String? hintText}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: const TextStyle(
      color: Color(0xFFD0D0D0),
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
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
