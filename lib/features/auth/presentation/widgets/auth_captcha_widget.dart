/// CAPTCHA widget pair for the registration password screen.
///
/// ── WHY THIS FILE EXISTS ─────────────────────────────────────────────────────
/// Previously [_MockCaptcha] and [_RealCaptcha] were private classes embedded
/// inside `register_detail_screen.dart`, which violated the Single
/// Responsibility Principle — the screen file was responsible for both screen
/// layout AND CAPTCHA widget rendering.
///
/// Extracting them here means:
///   - `register_detail_screen.dart` only handles its own layout.
///   - CAPTCHA widgets can be unit-tested independently.
///   - Switching from mock to real reCAPTCHA requires a change in this file
///     only, not inside the screen.
///
/// ── HOW TO USE ───────────────────────────────────────────────────────────────
/// ```dart
/// import 'auth_captcha_widget.dart';
///
/// AuthCaptchaWidget(
///   isChecked: _captchaVerified,
///   onVerified: (verified) => setState(() => _captchaVerified = verified),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/design_system/spacing.dart';
import 'package:software_project/core/design_system/typography.dart';

// ── reCAPTCHA configuration ───────────────────────────────────────────────────
//
// HOW TO SWITCH TO REAL reCAPTCHA (once backend provides the key):
//   1. Go to https://www.google.com/recaptcha/admin/create
//   2. Select reCAPTCHA v2 → "I'm not a robot" checkbox
//   3. Add your Android package name and iOS bundle ID
//   4. Copy the SITE KEY into [kRecaptchaSiteKey] below
//   5. Give the SECRET KEY to your backend developer
//   6. Add to pubspec.yaml: flutter_recaptcha_v2_compat: ^1.0.5
//   7. Set [kRecaptchaEnabled] = true — no other file needs to change.

/// Set to `true` once the real reCAPTCHA site key is configured.
const bool kRecaptchaEnabled = false;

/// Your Google reCAPTCHA v2 site key (public — safe to commit).
/// Obtain from https://www.google.com/recaptcha/admin/create
const String kRecaptchaSiteKey = 'YOUR_RECAPTCHA_SITE_KEY_HERE';

// ── Public facade ─────────────────────────────────────────────────────────────

/// Renders either the real reCAPTCHA widget or the mock checkbox depending on
/// [kRecaptchaEnabled].
///
/// [isChecked] — current checked state (only meaningful when mock is active).
/// [onVerified] — called with `true` when CAPTCHA is passed, `false` when reset.
///
/// The screen only reads the bool returned through [onVerified] and does not
/// need to know which variant is displayed.
class AuthCaptchaWidget extends StatelessWidget {
  /// Whether the mock checkbox is currently ticked.
  /// Ignored when [kRecaptchaEnabled] is true.
  final bool isChecked;

  /// Called whenever the verification state changes.
  /// `true` → user has passed CAPTCHA / ticked mock box.
  /// `false` → CAPTCHA was reset / user unticked.
  final ValueChanged<bool> onVerified;

  const AuthCaptchaWidget({
    super.key,
    required this.isChecked,
    required this.onVerified,
  });

  @override
  Widget build(BuildContext context) {
    if (kRecaptchaEnabled) {
      return _RealCaptcha(
        siteKey: kRecaptchaSiteKey,
        onVerified: (token) => onVerified(token != null),
      );
    }
    return _MockCaptcha(
      isChecked: isChecked,
      onChanged: (v) => onVerified(v ?? false),
    );
  }
}

// ── Real reCAPTCHA ────────────────────────────────────────────────────────────

/// Real reCAPTCHA v2 widget using `flutter_recaptcha_v2_compat`.
///
/// Only instantiated when [kRecaptchaEnabled] is `true`.
/// Until the package is added, [_MockCaptcha] is shown instead.
class _RealCaptcha extends StatelessWidget {
  /// The public site key from Google reCAPTCHA admin console.
  final String siteKey;

  /// Called with the one-time token on success, or `null` on failure/timeout.
  final void Function(String? token) onVerified;

  const _RealCaptcha({required this.siteKey, required this.onVerified});

  @override
  Widget build(BuildContext context) {
    // Uncomment once flutter_recaptcha_v2_compat is added to pubspec.yaml:
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
    return _MockCaptcha(
      isChecked: false,
      onChanged: (v) => onVerified(v == true ? 'mock-token' : null),
    );
  }
}

// ── Mock CAPTCHA ──────────────────────────────────────────────────────────────

/// Placeholder "I'm not a robot" checkbox used when [kRecaptchaEnabled] is
/// `false`.
///
/// Styled to resemble a real reCAPTCHA widget so the UI looks consistent
/// during development and testing.
///
/// Remove or replace with [_RealCaptcha] once the real key is configured.
class _MockCaptcha extends StatelessWidget {
  /// Whether the checkbox is currently ticked.
  final bool isChecked;

  /// Called when the checkbox value changes.
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
            mainAxisSize: MainAxisSize.min,
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
