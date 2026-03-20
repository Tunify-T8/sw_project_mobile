import 'package:flutter/material.dart';
import 'package:software_project/core/design_system/colors.dart';

/// A show/hide toggle icon used on password fields.
///
/// Place this as the [suffixIcon] of an [AppTextField].
class VisibilityToggle extends StatelessWidget {
  /// Whether the password is currently obscured.
  final bool isObscured;

  /// Called when the user taps the icon.
  final VoidCallback onToggle;

  const VisibilityToggle({
    super.key,
    required this.isObscured,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.onBackgroundMuted,
        size: 20,
      ),
      onPressed: onToggle,
    );
  }
}
