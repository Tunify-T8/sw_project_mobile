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

/// Forgot password screen (images 12 & 13).
///
/// Email shown in a field (pre-filled from [PasswordScreen]).
/// Body copy matches screenshot exactly.
/// "Need help? visit our Help Center" inline blue link.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String? initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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

  Future<void> _onSend() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await ref
        .read(authControllerProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Always navigate — never reveal whether email exists (API spec).
    Navigator.pushNamed(
      context,
      AppRoutes.checkYourEmail,
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
              // ── Header row ────────────────────────────────────────
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
                    // ── Email field ───────────────────────────────
                    AppTextField(
                      controller: _emailController,
                      hintText: 'Your email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // ── Body copy with inline link (image 13) ─────
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMuted,
                        children: [
                          const TextSpan(
                            text:
                                'If the email address is in our database, we will send you an '
                                'email to reset your password. Need help? ',
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
                    const SizedBox(height: AppSpacing.xl),

                    // ── Send reset link ───────────────────────────
                    AppButton(
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
