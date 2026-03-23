import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/shared/ui/widgets/app_back_button.dart';
import 'package:software_project/shared/ui/widgets/app_button.dart';
import 'package:software_project/shared/ui/widgets/app_text_field.dart';
import 'package:software_project/features/auth/presentation/widgets/visibility_toggle.dart';

/// Account linking screen — shown when a user taps "Sign in with Google"
/// but their Google email is already registered with a local password.
///
/// This is Scenario 3 from the Tunify OAuth API doc:
///   POST /auth/google → { requiresLinking: true, linkingToken: "..." }
///
/// The user enters their existing Tunify password to confirm they own
/// the account. On success, Google is permanently linked and they are
/// logged in. Future logins can use either Google or password.
///
/// The [linkingToken] expires in 10 minutes — if it expires the user
/// must tap "Sign in with Google" again.
class GoogleAccountLinkingScreen extends ConsumerStatefulWidget {
  /// The linkingToken from [GoogleAccountLinkingRequiredFailure].
  /// Expires in 10 minutes.
  final String linkingToken;

  /// The Google email address shown to the user.
  final String email;

  const GoogleAccountLinkingScreen({
    super.key,
    required this.linkingToken,
    required this.email,
  });

  @override
  ConsumerState<GoogleAccountLinkingScreen> createState() =>
      _GoogleAccountLinkingScreenState();
}

class _GoogleAccountLinkingScreenState
    extends ConsumerState<GoogleAccountLinkingScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLink() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authControllerProvider.notifier)
        .linkGoogleAccount(
          linkingToken: widget.linkingToken,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && previous?.isLoading == true) {
            // Linking succeeded — navigate to home.
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          }
        },
        error: (e, _) {
          final message = e is Failure ? e.message : 'Linking failed.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  0,
                ),
                child: AppBackButtonRow(title: 'Link Google account'),
              ),

              const SizedBox(height: AppSpacing.xxl),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Explanation ──────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'This email is already registered',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onBackground,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'The Google account (${widget.email}) is linked '
                            'to an existing Tunify account. Enter your '
                            'Tunify password below to link them together.\n\n'
                            'After linking, you can sign in with either '
                            'Google or your password.',
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Email display ────────────────────────────────────
                    Text('Email address', style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.xs),
                    Text(widget.email, style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Password field ───────────────────────────────────
                    AppTextField(
                      controller: _passwordController,
                      hintText: 'Your Tunify password',
                      obscureText: _obscurePassword,
                      suffixIcon: VisibilityToggle(
                        isObscured: _obscurePassword,
                        onToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Link button ──────────────────────────────────────
                    AppButton(
                      label: 'Link accounts',
                      onPressed: _onLink,
                      style: AppButtonStyle.primary,
                      isLoading: isLoading,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // ── Cancel ───────────────────────────────────────────
                    AppButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      style: AppButtonStyle.outlined,
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
