import 'package:flutter/material.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/utils/url_launcher_util.dart';
import 'package:software_project/core/utils/validators.dart';
import 'package:software_project/features/auth/presentation/widgets/auth_form_fields.dart';

/// Password creation screen for new users (register path).
///
/// Email is shown as plain text — entered on the previous screen.
/// On Continue → [TellUsMoreScreen] with the email and password forwarded.
class RegisterDetailScreen extends StatefulWidget {
  final String email;
  const RegisterDetailScreen({super.key, required this.email});

  @override
  State<RegisterDetailScreen> createState() => _RegisterDetailScreenState();
}

class _RegisterDetailScreenState extends State<RegisterDetailScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  /// TODO: Replace with real reCAPTCHA once backend provides site key.
  bool _captchaChecked = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    if (!_captchaChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the CAPTCHA verification.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushNamed(
        context,
        AppRoutes.tellUsMore,
        arguments: {
          'email': widget.email,
          'password': _passwordController.text,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                  child: AppBackButtonRow(title: 'Create an account'),
                ),

                const SizedBox(height: AppSpacing.xxl),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email shown as plain text — confirmed on previous screen.
                      AuthEmailDisplay(email: widget.email),
                      const SizedBox(height: AppSpacing.xl),

                      AppTextField(
                        controller: _passwordController,
                        hintText: 'Your Password (min: 6 characters)',
                        obscureText: _obscurePassword,
                        suffixIcon: VisibilityToggle(
                          isObscured: _obscurePassword,
                          onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: Validators.password,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // TODO: Replace with real reCAPTCHA widget.
                      _MockCaptcha(
                        isChecked: _captchaChecked,
                        onChanged: (v) =>
                            setState(() => _captchaChecked = v ?? false),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      AppButton(
                        label: 'Continue',
                        onPressed: _onContinue,
                        style: AppButtonStyle.primary,
                        isLoading: _isLoading,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: AppSpacing.base),

                      AuthLink(
                        label: 'Need help?',
                        onTap: () => UrlLauncherUtil.open(
                          context,
                          UrlLauncherUtil.helpCenter,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mock CAPTCHA ──────────────────────────────────────────────────────────────

/// Placeholder for the real reCAPTCHA widget.
/// TODO: Replace entirely once backend provides the reCAPTCHA site key.
class _MockCaptcha extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const _MockCaptcha({required this.isChecked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            checkColor: Colors.white,
            side: const BorderSide(color: AppColors.onBackgroundMuted),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text("I'm not a robot", style: AppTextStyles.body),
          const Spacer(),
          Column(
            children: [
              const Icon(Icons.security, color: AppColors.primary, size: 28),
              const SizedBox(height: 2),
              Text(
                'reCAPTCHA',
                style: AppTextStyles.caption.copyWith(fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
