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
/// Reached from [EmailEntryScreen] after the backend confirms the email exists.
///
/// [showAccountExistsNotice] — set to `true` when the user arrived via
/// "Create an account" but the email is already registered. Displays a
/// "We noticed that an account already exists" banner so the user
/// understands why they were redirected here.
///
/// ── Key assignment ────────────────────────────────────────────────────────────
/// Widget keys follow the constants in `test/features/auth/helpers/auth_selectors.dart`
/// (AuthKeys.loginPasswordField, AuthKeys.loginContinueButton,
///  AuthKeys.forgotPasswordLink) so automated tests can locate them
/// without relying on fragile text finders.
class PasswordScreen extends ConsumerStatefulWidget {
  /// The email address pre-filled from the previous screen.
  final String email;

  /// When `true`, shows the "account already exists" banner at the top.
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

  /// Whether the password text is currently hidden (dots).
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates the form and delegates login to [AuthController.login].
  ///
  /// Navigation and error display are handled reactively via [ref.listen]
  /// in [build] — this method only triggers the operation.
  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;

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
            // Account exists but email not verified — redirect to verify screen.
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
                    // Shown only when the user arrived via "Create account"
                    // flow but their email was already registered.
                    if (widget.showAccountExistsNotice) ...[
                      Text(
                        'We noticed that an account already exists for this '
                        'email. Please sign in below',
                        style: AppTextStyles.bodyMuted,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // ── Email as plain text (not editable) ──────────────
                    Text(
                      'Your email address or profile URL',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(widget.email, style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Password field ──────────────────────────────────
                    // Key: AuthKeys.loginPasswordField
                    AppTextField(
                      key: const Key('login_password_field'),
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
                    // Key: AuthKeys.loginContinueButton
                    AppButton(
                      key: const Key('login_continue_button'),
                      label: 'Continue',
                      onPressed: _onContinue,
                      style: AppButtonStyle.primary,
                      isLoading: isLoading,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // ── Forgot password link ────────────────────────────
                    // Key: AuthKeys.forgotPasswordLink
                    GestureDetector(
                      key: const Key('forgot_password_link'),
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
