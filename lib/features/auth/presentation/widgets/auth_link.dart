import 'package:flutter/material.dart';
import 'package:software_project/core/design_system/colors.dart';

/// A tappable text link styled consistently across all auth screens.
///
/// Used for: "Need help?", "Forgot your password?", "Resend code",
/// and any other inline clickable text in the auth flow.
///
/// The text is rendered in [AppColors.link] (blue) with no underline,
/// left-aligned by default.
///
/// Usage:
/// ```dart
/// AuthLink(
///   label: 'Need help?',
///   onTap: () => UrlLauncherUtil.open(context, UrlLauncherUtil.helpCenter),
/// )
///
/// AuthLink(
///   label: 'Forgot your password?',
///   onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
/// )
/// ```
class AuthLink extends StatelessWidget {
  /// The text displayed as the link.
  final String label;

  /// Called when the user taps the link.
  final VoidCallback onTap;

  /// Font size. Defaults to 14.
  final double fontSize;

  const AuthLink({
    super.key,
    required this.label,
    required this.onTap,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: AppColors.link,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
