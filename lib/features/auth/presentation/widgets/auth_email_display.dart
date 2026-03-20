import 'package:flutter/material.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';

/// Displays a confirmed email address as plain text (not inside an input field).
///
/// Used on [PasswordScreen] and [RegisterDetailScreen] where the email was
/// entered on a previous screen and only needs to be shown, not edited.
///
/// Layout:
///   Your email address or profile URL   ← muted caption
///   robin.banks@example.com             ← body text (the actual email)
///
/// Usage:
/// ```dart
/// AuthEmailDisplay(email: widget.email)
/// ```
class AuthEmailDisplay extends StatelessWidget {
  /// The email address to display.
  final String email;

  const AuthEmailDisplay({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your email address or profile URL', style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.xs),
        Text(email, style: AppTextStyles.body),
      ],
    );
  }
}
