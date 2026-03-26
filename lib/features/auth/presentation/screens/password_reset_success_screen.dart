import 'package:flutter/material.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/shared/ui/widgets/app_back_button.dart';
import 'package:software_project/shared/ui/widgets/app_button.dart';

/// Password reset success screen.
///
/// Shown after the user successfully resets their password in
/// [ResetPasswordScreen]. Confirms success and sends the user
/// back to the login screen.
class PasswordResetSuccessScreen extends StatelessWidget {
  final String email;
  const PasswordResetSuccessScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                0,
              ),
              child: AppBackButtonRow(title: 'Reset password'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Success icon ──────────────────────────────────────
                  const Center(
                    child: Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primary,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Success message ───────────────────────────────────
                  const Text(
                    'Password reset successfully',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Your password for $email has been updated. '
                    'You can now sign in with your new password.',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Back to login ─────────────────────────────────────
                  AppButton(
                    label: 'Back to login',
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.signInOrCreate,
                      (route) => route.settings.name == AppRoutes.landing,
                    ),
                    style: AppButtonStyle.primary,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
