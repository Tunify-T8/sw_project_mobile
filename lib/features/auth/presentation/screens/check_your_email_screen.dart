import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/shared/ui/widgets/app_back_button.dart';
import 'package:software_project/shared/ui/widgets/app_button.dart';
import 'package:software_project/core/utils/url_launcher_util.dart';

/// Shown after a password reset link has been sent.
class CheckYourEmailScreen extends StatelessWidget {
  final String email;
  const CheckYourEmailScreen({super.key, required this.email});

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
                  const Text(
                    'Check your email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Show the email address where the reset link was sent.
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMuted,
                      children: [
                        const TextSpan(
                          text:
                              "We've sent instructions on how to change your "
                              'password to ',
                        ),
                        TextSpan(
                          text: email,
                          style: const TextStyle(
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

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
                  const SizedBox(height: AppSpacing.lg),

                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.caption,
                      children: [
                        const TextSpan(
                          text:
                              'Did not receive the email? Check your spam folder or ',
                        ),
                        TextSpan(
                          text: 'visit our Help Center',
                          style: const TextStyle(color: AppColors.link),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => UrlLauncherUtil.open(
                              context,
                              UrlLauncherUtil.helpCenter,
                            ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
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
