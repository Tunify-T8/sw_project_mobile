import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/utils/validators.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/shared/ui/widgets/app_back_button.dart';
import 'package:software_project/shared/ui/widgets/app_button.dart';
import 'package:software_project/shared/ui/widgets/app_text_field.dart';
import 'package:software_project/core/utils/url_launcher_util.dart';

/// Forgot password screen — entry point for the password-reset flow.
///
/// The user enters their registered email and taps "Send reset link".
/// The screen then navigates to [ResetPasswordScreen] regardless of whether
/// the email exists in the database. This is intentional — never revealing
/// email existence is a security requirement (prevents account enumeration).
///
/// ── Key assignment ────────────────────────────────────────────────────────────
/// Widget keys follow `AuthKeys` in `test/features/auth/helpers/auth_selectors.dart`:
///   - [AuthKeys.forgotPasswordEmailField] → email [AppTextField]
///   - [AuthKeys.sendResetLinkButton]      → "Send reset link" [AppButton]
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Optional pre-filled email (passed from [PasswordScreen] via route args).
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Whether the "Send reset link" button is currently showing a spinner.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Validates the email field and calls [AuthController.forgotPassword].
  ///
  /// Always navigates to [ResetPasswordScreen] after the call — even when the
  /// email is not found — to prevent account enumeration (security spec).
  Future<void> _onSend() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await ref
        .read(authControllerProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushNamed(
      context,
      AppRoutes.resetPassword,
      arguments: {'email': _emailController.text.trim()},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
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
                    // ── Email field ───────────────────────────────────
                    // Key: AuthKeys.forgotPasswordEmailField
                    AppTextField(
                      key: const Key('forgot_password_email_field'),
                      controller: _emailController,
                      hintText: 'Your email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // ── Help copy ─────────────────────────────────────
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMuted,
                        children: [
                          const TextSpan(text: 'Need help? '),
                          TextSpan(
                            text: 'Visit our Help Center',
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
                    const SizedBox(height: AppSpacing.xl),

                    // ── Send reset link button ─────────────────────────
                    // Key: AuthKeys.sendResetLinkButton
                    AppButton(
                      key: const Key('send_reset_link_button'),
                      label: 'Send reset link',
                      onPressed: _onSend,
                      style: AppButtonStyle.primary,
                      isLoading: _isLoading,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
