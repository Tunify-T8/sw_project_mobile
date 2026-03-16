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

/// Reset password screen — entered via deep link from the reset email.
///
/// Accepts the user's email, the 6-char reset token, and a new password.
/// The "Also sign me out everywhere" checkbox maps to [signoutAll] in
/// the Tunify API — defaults to true per API spec.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? email;
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

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Delegate reset logic to the controller; UI reacts to state changes.
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

    // Listen for controller state changes to handle success and errors.
    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous?.isLoading == true) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.landing,
              (route) => false,
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
      appBar: _buildAppBar(),
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
                const SizedBox(height: AppSpacing.xxl),

                Text('Email address', style: AppTextStyles.fieldLabel),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _emailController,
                  hintText: 'Your email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.base),

                Text(
                  'Reset code (from email)',
                  style: AppTextStyles.fieldLabel,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _tokenController,
                  hintText: '6-character code',
                  validator: Validators.verificationToken,
                ),
                const SizedBox(height: AppSpacing.base),

                Text('New password', style: AppTextStyles.fieldLabel),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
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

                Text('Confirm new password', style: AppTextStyles.fieldLabel),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
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
                        side: const BorderSide(
                          color: AppColors.onBackgroundMuted,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Also sign me out everywhere',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                AppButton(
                  label: 'Save',
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

  AppBar _buildAppBar() => AppBar(
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
  );
}
