import 'package:flutter/material.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';
import 'package:software_project/core/utils/url_launcher_util.dart';
import 'package:software_project/core/utils/validators.dart';
import 'package:software_project/features/auth/presentation/widgets/auth_form_fields.dart';

// ── reCAPTCHA configuration ───────────────────────────────────────────────────
//
// HOW TO SET UP (once backend provides the key):
//   1. Go to https://www.google.com/recaptcha/admin/create
//   2. Select reCAPTCHA v2 → "I'm not a robot" checkbox
//   3. Add your Android package name and iOS bundle ID
//   4. Copy the SITE KEY (public) into _kRecaptchaSiteKey below
//   5. Give the SECRET KEY (private) to your backend developer
//   6. Add to pubspec.yaml:
//        flutter_recaptcha_v2_compat: ^1.0.5
//   7. Set _kRecaptchaEnabled = true
//
// Until the key is available, the mock checkbox is used instead.
// No other file needs to change.

const bool _kRecaptchaEnabled = false;
// ignore: unused_element
const String _kRecaptchaSiteKey = 'YOUR_RECAPTCHA_SITE_KEY_HERE';

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
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Holds the reCAPTCHA token when _kRecaptchaEnabled = true,
  // or true/false for the mock checkbox when disabled.
  bool _captchaVerified = false;

  // ── Reactive validity ─────────────────────────────────────────────────────
  // Recomputed on every keystroke and captcha change via setState.
  // The button reads this directly — no Form/GlobalKey needed for disabling.
  bool get _passwordValid =>
      Validators.password(_passwordController.text) == null;

  bool get _canContinue => _passwordValid && _captchaVerified;

  @override
  void initState() {
    super.initState();
    // Rebuild on every keystroke so _canContinue stays in sync.
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onContinue() {
    // Guard is redundant (button is null when !_canContinue) but kept for safety.
    if (!_canContinue) return;

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
                    AuthEmailDisplay(email: widget.email),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Password field ──────────────────────────────────
                    // Uses a plain AppTextField (no Form wrapper needed —
                    // validation state is tracked via _passwordValid getter).
                    AppTextField(
                      key: const Key('register_password_field'),
                      controller: _passwordController,
                      hintText: 'Your Password (min: 8 characters)',
                      obscureText: _obscurePassword,
                      suffixIcon: VisibilityToggle(
                        isObscured: _obscurePassword,
                        onToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      // Keep validator for inline error display when the user
                      // types something invalid — the button disabling is the
                      // primary guard but the inline message is still helpful.
                      validator: Validators.password,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── CAPTCHA ──────────────────────────────────────────
                    if (_kRecaptchaEnabled)
                      _RealCaptcha(
                        siteKey: _kRecaptchaSiteKey,
                        onVerified: (token) {
                          setState(() => _captchaVerified = token != null);
                        },
                      )
                    else
                      _MockCaptcha(
                        isChecked: _captchaVerified,
                        onChanged: (v) =>
                            setState(() => _captchaVerified = v ?? false),
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Continue button ──────────────────────────────────
                    // onPressed is null (→ greyed out / disabled) until both
                    // password is valid AND captcha is checked.
                    AppButton(
                      key: const Key('register_continue_button'),
                      label: 'Continue',
                      onPressed: _canContinue ? _onContinue : null,
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
    );
  }
}

// ── Real reCAPTCHA ────────────────────────────────────────────────────────────

/// Real reCAPTCHA v2 widget using flutter_recaptcha_v2_compat.
///
/// SETUP STEPS:
///   1. Add to pubspec.yaml: flutter_recaptcha_v2_compat: ^1.0.5
///   2. Run: flutter pub get
///   3. Set _kRecaptchaEnabled = true in this file
///   4. Set _kRecaptchaSiteKey to your actual site key
///
/// The widget displays a WebView with the Google "I'm not a robot" checkbox.
/// On success, [onVerified] receives the one-time-use token string.
/// Pass this token to your backend along with the registration payload.
/// Your backend verifies it at: https://www.google.com/recaptcha/api/siteverify
class _RealCaptcha extends StatelessWidget {
  final String siteKey;
  final void Function(String? token) onVerified;

  const _RealCaptcha({required this.siteKey, required this.onVerified});

  @override
  Widget build(BuildContext context) {
    // Uncomment the import and this widget body once the package is installed:
    //
    // import 'package:flutter_recaptcha_v2_compat/flutter_recaptcha_v2_compat.dart';
    //
    // return RecaptchaV2(
    //   apiKey: siteKey,
    //   apiSecret: '',  // Secret stays on the backend — never put it here.
    //   controller: RecaptchaV2Controller(),
    //   onVerifiedSuccessfully: (success) {
    //     if (success) onVerified('verified');
    //   },
    //   onVerifiedError: (err) => onVerified(null),
    // );

    // Temporary fallback until the package is added.
    return _MockCaptcha(
      isChecked: false,
      onChanged: (v) => onVerified(v == true ? 'mock-token' : null),
    );
  }
}

// ── Mock CAPTCHA ──────────────────────────────────────────────────────────────

/// Placeholder checkbox used when _kRecaptchaEnabled = false.
/// Remove this once the real reCAPTCHA is configured.
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
            key: const Key('captcha_checkbox'),
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
