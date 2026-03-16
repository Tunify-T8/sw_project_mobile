import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/core/utils/validators.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/shared/ui/widgets/app_back_button.dart';
import 'package:software_project/shared/ui/widgets/app_button.dart';
import 'package:software_project/shared/ui/widgets/app_text_field.dart';
import 'package:software_project/features/auth/presentation/widgets/visibility_toggle.dart';

/// Password entry screen for existing users (login path).
///
/// [showAccountExistsNotice] is true when the user arrived via
/// "Create an account" but the email is already registered —
/// shows the "We noticed that an account already exists" banner.
class PasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final bool showAccountExistsNotice;

  const PasswordScreen({
    super.key,
    required this.email,
    this.showAccountExistsNotice = false,
  });

  @override
  ConsumerState<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

    // Delegate login to the controller; UI reacts to state changes via ref.listen.
    await ref
        .read(authControllerProvider.notifier)
        .login(widget.email, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    // React to auth state changes (success / error) via ref.listen.
    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && previous?.isLoading == true) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          }
        },
        error: (e, _) {
          if (e is UnverifiedUserFailure) {
            Navigator.pushNamed(
              context,
              AppRoutes.verifyEmail,
              arguments: {'email': widget.email},
            );
          } else {
            final message = e is Failure ? e.message : 'Login failed.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  0,
                ),
                child: AppBackButtonRow(title: 'Welcome back!'),
              ),

              const SizedBox(height: AppSpacing.xl),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── "Account already exists" notice ─────────────────
                    if (widget.showAccountExistsNotice) ...[
                      Text(
                        'We noticed that an account already exists for this email. '
                        'Please sign in below',
                        style: AppTextStyles.bodyMuted,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // ── Email as plain text (not in a field) ────────────
                    Text(
                      'Your email address or profile URL',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(widget.email, style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Password field ──────────────────────────────────
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
                      validator: Validators.loginPassword,
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // ── Continue button ─────────────────────────────────
                    AppButton(
                      label: 'Continue',
                      onPressed: _onContinue,
                      style: AppButtonStyle.primary,
                      isLoading: isLoading,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // ── Forgot password — blue link, left-aligned ───────
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.forgotPassword,
                        arguments: {'email': widget.email},
                      ),
                      child: const Text(
                        'Forgot your password?',
                        style: TextStyle(fontSize: 14, color: AppColors.link),
                      ),
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
