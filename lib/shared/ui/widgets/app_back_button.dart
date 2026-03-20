import 'package:flutter/material.dart';
import 'package:software_project/core/design_system/colors.dart';

/// A page header row consisting of a grey-circle back button and a title.
///
/// This widget belongs in [shared/ui/widgets] because the grey-circle
/// back-button pattern is used consistently across all sub-screens in
/// the app, regardless of which feature they belong to.
///
/// Layout: [grey circle with chevron] [12 dp gap] [title text (expanded)]
///
/// The back button calls [Navigator.pop] by default. Supply [onBack]
/// to override the navigation behaviour if needed.
///
/// Usage — place inside [SafeArea] at the top of the screen body
/// (not inside an [AppBar]):
/// ```dart
/// Padding(
///   padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
///   child: AppBackButtonRow(title: 'Welcome back!'),
/// )
/// ```
class AppBackButtonRow extends StatelessWidget {
  /// The page title displayed to the right of the back button.
  final String title;

  /// Custom back navigation. Defaults to [Navigator.pop] if not provided.
  final VoidCallback? onBack;

  const AppBackButtonRow({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Grey circle containing the back chevron icon.
        _CircleBackButton(onTap: onBack ?? () => Navigator.of(context).pop()),
        const SizedBox(width: 12),
        // Title expands to fill remaining row width.
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
        ),
      ],
    );
  }
}

/// The 36 × 36 circular grey back button used inside [AppBackButtonRow].
///
/// Private to this file — import [AppBackButtonRow] instead.
class _CircleBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CircleBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.surfaceHigh,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.onBackground,
          size: 16,
        ),
      ),
    );
  }
}
