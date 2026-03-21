import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/utils/url_launcher_util.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';

/// Sign in or create account — OAuth choice + email entry screen.
///
/// [initialMode] is set by the landing screen:
/// - `'login'`  → user pressed "Log in"
/// - `'create'` → user pressed "Create an account" (default / null)
class SignInOrCreateScreen extends ConsumerWidget {
  final String? initialMode;
  const SignInOrCreateScreen({super.key, this.initialMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for successful Google sign-in and navigate to home.
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

              // Facebook — no backend support yet.
              _OAuthButton(
                label: 'Continue with Facebook',
                backgroundColor: AppColors.facebookBlue,
                icon: const Icon(Icons.facebook, color: Colors.white, size: 22),
                onTap: () => _onUnsupportedOAuth(context, 'Facebook'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Google — fully wired end-to-end.
              // Requires: serverClientId in google_sign_in_service.dart
              // + backend /auth/google endpoint live.
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

              // Apple — no backend support yet.
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
    final success = await ref
        .read(authControllerProvider.notifier)
        .loginWithGoogle();

    if (!context.mounted) return;

    // If success=true, ref.listen above handles the navigation to home.
    // If success=false, the user cancelled — nothing to do.
    // If success=false due to an error (e.g. serverClientId not set),
    // the controller state is AsyncError and we show a snackbar.
    if (!success) {
      final state = ref.read(authControllerProvider);
      if (state is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in is not available yet.')),
        );
      }
    }
  }

  /// Shows a "coming soon" snackbar for OAuth providers not yet supported.
  void _onUnsupportedOAuth(BuildContext context, String provider) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$provider sign-in coming soon.')));
  }
}

// ── Legal text ────────────────────────────────────────────────────────────────

class _LegalText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.caption.copyWith(height: 1.6),
        children: [
          const TextSpan(
            text:
                'By clicking on any of the "Continue" buttons below, you '
                "agree to SoundCloud's ",
          ),
          TextSpan(
            text: 'Terms of Use',
            style: const TextStyle(color: AppColors.link),
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  UrlLauncherUtil.open(context, UrlLauncherUtil.termsOfUse),
          ),
          const TextSpan(text: ' and acknowledge our '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(color: AppColors.link),
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

// ── Email entry field ─────────────────────────────────────────────────────────

class _EmailEntryField extends StatefulWidget {
  final void Function(String email) onSubmit;
  const _EmailEntryField({required this.onSubmit});

  @override
  State<_EmailEntryField> createState() => _EmailEntryFieldState();
}

class _EmailEntryFieldState extends State<_EmailEntryField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
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
              borderSide: const BorderSide(
                color: AppColors.onBackground,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onSubmit(_controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: AppColors.buttonPrimaryText,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}

// ── OAuth Button ──────────────────────────────────────────────────────────────

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
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        ),
        child: Row(
          children: [
            SizedBox(width: 24, child: icon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
