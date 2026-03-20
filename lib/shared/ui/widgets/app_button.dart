import 'package:flutter/material.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/typography.dart';

/// The four visual styles an [AppButton] can take.
///
/// Choose the style that matches the action's importance and intent:
/// - [primary]     — the main call-to-action on a screen (e.g. "Continue")
/// - [secondary]   — an alternative action (e.g. "Log in" on landing)
/// - [outlined]    — a low-emphasis action (e.g. "Back to login")
/// - [destructive] — an irreversible action (e.g. "Delete account")
enum AppButtonStyle {
  /// White background, black text.
  /// Used for the primary CTA on landing and all auth form submit buttons.
  primary,

  /// Soft blue (#C6D8F8) background, black text.
  /// Used for the "Log in" button on the landing screen.
  secondary,

  /// Transparent background with a grey border, white text.
  /// Used for low-emphasis secondary actions.
  outlined,

  /// Pink-red background, white text.
  /// Used only for irreversible destructive actions such as account deletion.
  destructive,
}

/// A standardised full-width button shared across the entire app.
///
/// This widget belongs in [shared/ui/widgets] because it is generic —
/// it has no knowledge of auth, feed, or any other feature. Any feature
/// can import and use it.
///
/// Handles loading state by replacing the label with a [CircularProgressIndicator]
/// and disabling taps to prevent duplicate submissions.
///
/// Usage:
/// ```dart
/// AppButton(
///   label: 'Continue',
///   onPressed: _onSubmit,
///   style: AppButtonStyle.primary,
///   isLoading: _isLoading,
///   borderRadius: 4,
/// )
/// ```
class AppButton extends StatelessWidget {
  /// The text displayed on the button.
  final String label;

  /// Called when the button is tapped. Set to null to disable permanently.
  final VoidCallback? onPressed;

  /// Determines the button's background and text colours.
  final AppButtonStyle style;

  /// When true, shows a spinner instead of the label and blocks taps.
  final bool isLoading;

  /// The button's height in logical pixels. Defaults to 52.
  final double height;

  /// The corner radius. Use 4 for flat form buttons, 28 for pill buttons.
  final double borderRadius;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
    this.height = 52.0,
    this.borderRadius = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (style) {
      case AppButtonStyle.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.buttonPrimaryText,
            disabledBackgroundColor: AppColors.buttonPrimary.withValues(
              alpha: 0.5,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            textStyle: AppTextStyles.buttonLabel,
          ),
          child: _child(AppColors.buttonPrimaryText),
        );

      case AppButtonStyle.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonSecondary,
            foregroundColor: AppColors.buttonSecondaryText,
            disabledBackgroundColor: AppColors.buttonSecondary.withValues(
              alpha: 0.5,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            textStyle: AppTextStyles.buttonLabel,
          ),
          child: _child(AppColors.buttonSecondaryText),
        );

      case AppButtonStyle.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.onBackground,
            side: const BorderSide(color: AppColors.border, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            textStyle: AppTextStyles.buttonLabel,
          ),
          child: _child(AppColors.onBackground),
        );

      case AppButtonStyle.destructive:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deleteRed,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.deleteRed.withValues(alpha: 0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            textStyle: AppTextStyles.buttonLabel,
          ),
          child: _child(Colors.white),
        );
    }
  }

  /// Returns the spinner during loading or the label text otherwise.
  Widget _child(Color spinnerColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(color: spinnerColor, strokeWidth: 2),
      );
    }
    return Text(label);
  }
}
