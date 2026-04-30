import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/core/utils/url_launcher_util.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';

/// Sign in or create account — OAuth choice + email entry screen.

class SignInOrCreateScreen extends ConsumerWidget {
  final String? initialMode;
  const SignInOrCreateScreen({super.key, this.initialMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              const Text(
                'Sign in or create\nan account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onBackground,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _LegalText(),
              const SizedBox(height: AppSpacing.xxl),

              _OAuthButton(
                label: 'Continue with Facebook',
                backgroundColor: AppColors.facebookBlue,
                icon: const Icon(Icons.facebook, color: Colors.white, size: 22),
                onTap: () => _onUnsupportedOAuth(context, 'Facebook'),
              ),
              const SizedBox(height: AppSpacing.md),

              _OAuthButton(
                label: 'Continue with Google',
                backgroundColor: AppColors.googleGrey,
                icon: const Icon(
                  Icons.g_mobiledata,
                  color: Colors.white,
                  size: 26,
                ),
                onTap: () => _onGoogleSignIn(context, ref),
              ),
              const SizedBox(height: AppSpacing.md),

              _OAuthButton(
                label: 'Continue with Apple',
                backgroundColor: AppColors.appleBlack,
                icon: const Icon(Icons.apple, color: Colors.white, size: 22),
                onTap: () => _onUnsupportedOAuth(context, 'Apple'),
              ),

              const SizedBox(height: AppSpacing.xl),

              const Text(
                'Or with email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // FIX (M1-005): Tap goes directly to EmailEntryScreen.
              _EmailEntryField(
                onSubmit: (email) => Navigator.pushNamed(
                  context,
                  AppRoutes.emailEntry,
                  arguments: {'email': email, 'mode': initialMode ?? 'create'},
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              GestureDetector(
                onTap: () =>
                    UrlLauncherUtil.open(context, UrlLauncherUtil.helpCenter),
                child: const Text(
                  'Need help?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.link,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final outcome = await ref
        .read(authControllerProvider.notifier)
        .loginWithGoogle();

    if (!context.mounted) return;

    switch (outcome) {
      case GoogleSignInOutcome.success:
        // ref.listen handles navigation to home.
        break;

      case GoogleSignInOutcome.cancelled:
        // User dismissed — do nothing.
        break;

      case GoogleSignInOutcome.requiresLinking:
        // Read the failure from controller state to get linkingToken + email.
        final err = ref.read(authControllerProvider).error;
        if (err is GoogleAccountLinkingRequiredFailure && context.mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.googleAccountLinking,
            arguments: {'linkingToken': err.linkingToken, 'email': err.email},
          );
        }
        break;

      case GoogleSignInOutcome.error:
        if (context.mounted) {
          final err = ref.read(authControllerProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                err is Failure ? err.message : 'Google sign-in failed.',
              ),
            ),
          );
        }
        break;
    }
  }

  void _onUnsupportedOAuth(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in is not yet supported.')),
    );
  }
}

// ── OAuth button ──────────────────────────────────────────────────────────────

class _OAuthButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Widget icon;
  final VoidCallback onTap;

  const _OAuthButton({
    required this.label,
    required this.backgroundColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: icon,
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Email entry field ─────────────────────────────────────────────────────────

/// Tappable placeholder that navigates to [EmailEntryScreen] on any tap.
///
/// FIX (M1-005): [AbsorbPointer] + [readOnly] prevent the keyboard from
/// opening on this screen. The Continue button is always enabled since
/// validation happens on [EmailEntryScreen].
class _EmailEntryField extends StatelessWidget {
  final void Function(String email) onSubmit;
  const _EmailEntryField({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSubmit(''),
      child: Column(
        children: [
          AbsorbPointer(
            child: TextField(
              key: const Key('sign_in_email_field'),
              readOnly: true,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyles.inputText,
              cursorColor: AppColors.onBackground,
              decoration: InputDecoration(
                hintText: 'Your email address or profile URL',
                hintStyle: AppTextStyles.inputHint,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              key: const Key('sign_in_continue_button'),
              onPressed: () => onSubmit(''),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onBackground,
                foregroundColor: AppColors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                textStyle: AppTextStyles.buttonLabel,
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legal text ────────────────────────────────────────────────────────────────

class _LegalText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodyMuted,
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Use',
            style: AppTextStyles.link,
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  UrlLauncherUtil.open(context, UrlLauncherUtil.termsOfUse),
          ),
          const TextSpan(text: ' and confirm that you have read our '),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTextStyles.link,
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  UrlLauncherUtil.open(context, UrlLauncherUtil.privacyPolicy),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
