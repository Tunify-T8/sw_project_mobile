import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/utils/url_launcher_util.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';

// ── Google OAuth configuration ────────────────────────────────────────────────
//
// HOW TO COMPLETE GOOGLE SIGN-IN (once backend provides credentials):
//
//   FRONTEND (this file — already wired):
//     1. In google_sign_in_service.dart, uncomment serverClientId and set it
//        to the Web Client ID from Google Cloud Console.
//     2. That's all the Flutter side needs. The rest is already implemented.
//
//   BACKEND (your backend developer):
//     1. Receive the idToken POST'd to your /auth/google endpoint.
//     2. Verify it using google-auth-library (Node) or equivalent.
//     3. Check token.audience matches your Web Client ID.
//     4. Create or fetch the user, then return your own JWT pair.
//
//   Once the backend endpoint is live:
//     1. Implement OAuthLoginUseCase.call(idToken) to POST to /auth/google.
//     2. In AuthController.loginWithGoogle(), call the use case after signIn().

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

              // Facebook — no backend support yet, shows coming soon.
              _OAuthButton(
                label: 'Continue with Facebook',
                backgroundColor: AppColors.facebookBlue,
                icon: const Icon(Icons.facebook, color: Colors.white, size: 22),
                onTap: () => _onUnsupportedOAuth(context, 'Facebook'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Google — fully wired. Needs serverClientId in
              // google_sign_in_service.dart and the backend /auth/google endpoint.
              _OAuthButton(
                label: 'Continue with Google',
                backgroundColor: AppColors.googleGrey,
                icon: const Icon(
                  Icons.g_mobiledata,
                  color: Colors.white,
                  size: 26,
                ),
                //Note: the commented line below can be used to bypass
                //Google sign-in during development before the backend endpoint
                // is ready. It shows a coming soon message instead of the native dialog.:
                onTap: () => _onGoogleSignIn(context, ref),
                //onTap: () => _onUnsupportedOAuth(context, 'Google')
              ),
              const SizedBox(height: AppSpacing.md),

              // Apple — no backend support yet, shows coming soon.
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

  /// Handles Google Sign-In.
  ///
  /// Flow:
  ///   1. Calls GoogleSignInService.signIn() (native dialog).
  ///   2. If user cancels → does nothing.
  ///   3. If successful → currently a stub (backend endpoint pending).
  ///      Once /auth/google exists, OAuthLoginUseCase will post the idToken
  ///      and the controller will set state to data(user).
  ///
  /// What you see today in mock mode: the native Google dialog appears,
  /// but sign-in completes without setting an authenticated session because
  /// the backend call is not yet implemented. When the endpoint is ready,
  /// this screen needs no changes — only OAuthLoginUseCase and
  /// AuthController.loginWithGoogle() need to be completed.
  Future<void> _onGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(authControllerProvider.notifier)
        .loginWithGoogle();

    if (!context.mounted) return;

    if (!result) {
      // User cancelled or Google sign-in failed — nothing to do.
      return;
    }

    // TODO: Navigate to home once OAuthLoginUseCase is implemented and
    // AuthController.loginWithGoogle() sets state to data(user).
    // For now, show an informational message.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Google sign-in successful — backend endpoint coming soon.',
        ),
      ),
    );
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
