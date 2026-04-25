import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/core/utils/validators.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/shared/ui/widgets/app_button.dart';
import 'package:software_project/shared/ui/widgets/app_text_field.dart';
import 'package:software_project/features/auth/presentation/widgets/visibility_toggle.dart';

/// Reset password screen — the second step of the password-recovery flow.
///
/// Shown immediately after [ForgotPasswordScreen]. Displays an instruction
/// banner telling the user to check their inbox, then collects:
///   - Their email address (pre-filled from route args).
///   - The 6-character reset code from the email.
///   - A new password and confirmation.
///   - Optional "sign out all devices" checkbox (default: true).
///
/// On success → [PasswordResetSuccessScreen].
/// On expired/invalid token → error snackbar, stays on this screen.
///
/// ── Key assignment ────────────────────────────────────────────────────────────
/// Widget keys follow `AuthKeys` in `test/features/auth/helpers/auth_selectors.dart`:
///   - [AuthKeys.resetTokenField]           → 6-char code [AppTextField]
///   - [AuthKeys.resetNewPasswordField]     → new password [AppTextField]
///   - [AuthKeys.resetConfirmPasswordField] → confirm password [AppTextField]
///   - [AuthKeys.resetSaveButton]           → "Reset password" [AppButton]
class ResetPasswordScreen extends ConsumerStatefulWidget {
  /// Email pre-filled from [ForgotPasswordScreen] route arguments.
  /// Editable in case the user arrived directly.
  final String? email;

  /// Optional pre-filled reset token (unused in current flow but kept
  /// for deep-link support).
  final String? resetToken;

  const ResetPasswordScreen({super.key, this.email, this.resetToken});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _tokenController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Whether the new-password field shows dots.
  bool _obscurePassword = true;

  /// Whether the confirm-password field shows dots.
  bool _obscureConfirm = true;

  /// When `true`, all active sessions are revoked after the reset.
  /// Default is `true` — protects against an attacker who triggered the reset
  /// staying logged in on another device.
  bool _signOutAll = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email ?? '');
    _tokenController = TextEditingController(text: widget.resetToken ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Validates the form and calls [AuthController.resetPassword].
  ///
  /// Navigation on success and error display are handled reactively via
  /// [ref.listen] in [build].
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          email: _emailController.text.trim(),
          token: _tokenController.text.trim().toUpperCase(),
          newPassword: _passwordController.text,
          confirmPassword: _confirmController.text,
          signoutAll: _signOutAll,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    // React to controller state changes for success navigation and errors.
    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous?.isLoading == true) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.passwordResetSuccess,
              (route) => route.settings.name == AppRoutes.landing,
              arguments: {'email': _emailController.text.trim()},
            );
          }
        },
        error: (e, _) {
          final message = e is Failure ? e.message : 'Reset failed.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.onBackground,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.base),
                Text('Change your password', style: AppTextStyles.screenTitle),
                const SizedBox(height: AppSpacing.md),

                // ── Instruction banner ────────────────────────────────
                // Shown while the user waits for the email to arrive.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.mail_outline,
                        color: AppColors.onBackgroundMuted,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _emailController.text.isNotEmpty
                              ? "If this email is in our database, we've sent "
                                    "a reset code to ${_emailController.text}. "
                                    "Check your spam folder if you don't see it."
                              : "If this email is in our database, we've sent "
                                    "you a reset code. Check your spam folder if "
                                    "you don't see it.",
                          style: AppTextStyles.bodyMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Email address ─────────────────────────────────────
                Text('Email address', style: AppTextStyles.fieldLabel),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _emailController,
                  hintText: 'Your email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.base),

                // ── Reset code ────────────────────────────────────────
                // Key: AuthKeys.resetTokenField
                Text(
                  'Reset code (from email)',
                  style: AppTextStyles.fieldLabel,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  key: const Key('reset_token_field'),
                  controller: _tokenController,
                  hintText: '6-character code',
                  validator: Validators.verificationToken,
                ),
                const SizedBox(height: AppSpacing.base),

                // ── New password ──────────────────────────────────────
                // Key: AuthKeys.resetNewPasswordField
                Text('New password', style: AppTextStyles.fieldLabel),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  key: const Key('reset_new_password_field'),
                  controller: _passwordController,
                  hintText: 'New password',
                  obscureText: _obscurePassword,
                  suffixIcon: VisibilityToggle(
                    isObscured: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.base),

                // ── Confirm password ──────────────────────────────────
                // Key: AuthKeys.resetConfirmPasswordField
                Text('Confirm new password', style: AppTextStyles.fieldLabel),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  key: const Key('reset_confirm_password_field'),
                  controller: _confirmController,
                  hintText: 'Confirm new password',
                  obscureText: _obscureConfirm,
                  suffixIcon: VisibilityToggle(
                    isObscured: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordController.text),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Sign out all devices toggle ────────────────────────
                // Default true — revokes all sessions for security.
                GestureDetector(
                  onTap: () => setState(() => _signOutAll = !_signOutAll),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _signOutAll,
                        onChanged: (v) =>
                            setState(() => _signOutAll = v ?? true),
                        activeColor: AppColors.primary,
                        checkColor: Colors.white,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Sign out of all other devices',
                          style: AppTextStyles.body,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Save / Reset password button ──────────────────────
                // Key: AuthKeys.resetSaveButton
                AppButton(
                  key: const Key('reset_save_button'),
                  label: 'Reset password',
                  onPressed: _onSave,
                  style: AppButtonStyle.primary,
                  isLoading: isLoading,
                  borderRadius: 4,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
