import 'package:flutter/material.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/typography.dart';

/// A standardised text input field shared across the entire app.
///
/// This widget belongs in [shared/ui/widgets] because it is generic —
/// it styles a text field consistently but knows nothing about which
/// feature is using it. It can be reused in auth, profile, or any
/// other feature.
///
/// Features:
/// - White cursor on the dark background ([AppColors.onBackground]).
/// - Consistent border: grey by default, white on focus, red on error.
/// - Supports hint text, keyboard type, password obscuring, and a
///   suffix icon (typically [VisibilityToggle] for password fields).
/// - Supports [readOnly] for displaying pre-filled values such as
///   an email address confirmed on a previous screen.
/// - Connects to Flutter's [Form] widget via the [validator] callback.
///
/// Usage:
/// ```dart
/// AppTextField(
///   controller: _emailController,
///   hintText: 'Your email address',
///   keyboardType: TextInputType.emailAddress,
///   validator: Validators.email,
/// )
/// ```
class AppTextField extends StatelessWidget {
  /// Controls the text content.
  final TextEditingController controller;

  /// Shown inside the field when it is empty.
  final String hintText;

  /// The keyboard layout shown when this field is focused.
  final TextInputType keyboardType;

  /// Called by [Form.validate()] — return null if valid, an error string
  /// if invalid. Use one of the static methods in [Validators].
  final String? Function(String?)? validator;

  /// When true the text is replaced with dots (for password fields).
  final bool obscureText;

  /// Displayed at the trailing edge of the field.
  /// Typically a [VisibilityToggle] on password fields.
  final Widget? suffixIcon;

  /// When true the user cannot edit the field.
  /// Used to display a pre-confirmed email on the password screen.
  final bool readOnly;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      style: AppTextStyles.inputText,
      cursorColor: AppColors.onBackground,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.inputHint,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.onBackground,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: AppTextStyles.inputError,
      ),
    );
  }
}
