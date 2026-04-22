/// Centralized widget selectors for all Module 1 / auth screens.
///
/// ── WHY THIS FILE EXISTS ─────────────────────────────────────────────────────
/// Project rules require all selectors to live in a single file so that any
/// label or key change in the production UI only needs one update here, not
/// inside every individual test file.
///
/// ── USAGE ────────────────────────────────────────────────────────────────────
/// ```dart
/// import 'auth_selectors.dart';
///
/// // Find a widget:
/// expect(find.byKey(AuthKeys.emailEntryField), findsOneWidget);
///
/// // Tap a button:
/// await tester.tap(AuthFinders.continueButton);
/// ```
///
/// ── STRUCTURE ────────────────────────────────────────────────────────────────
/// [AuthKeys]    — raw [Key] constants; assign these to widget `key:` params.
/// [AuthFinders] — ready-made [Finder] helpers built on top of [AuthKeys].
///                 Use these in test assertions and interactions.
// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Key constants ─────────────────────────────────────────────────────────────

/// Widget [Key] values for every interactive element across all auth screens.
///
/// Assign these directly in the production widget:
/// ```dart
/// AppTextField(key: AuthKeys.emailEntryField, ...)
/// ```
abstract class AuthKeys {
  // ── SignInOrCreateScreen / _EmailEntryField ──────────────────────────────
  /// The email [TextField] on the sign-in / create-account screen.
  static const Key signInEmailField = Key('sign_in_email_field');

  /// The "Continue" button on the sign-in / create-account screen.
  static const Key signInContinueButton = Key('sign_in_continue_button');

  // ── EmailEntryScreen ─────────────────────────────────────────────────────
  /// The email [AppTextField] on the dedicated email entry sub-screen.
  static const Key emailEntryField = Key('email_entry_field');

  /// The "Continue" button on the email entry sub-screen.
  static const Key emailEntryContinueButton = Key(
    'email_entry_continue_button',
  );

  // ── RegisterDetailScreen ─────────────────────────────────────────────────
  /// The password [AppTextField] on the password creation screen.
  static const Key registerPasswordField = Key('register_password_field');

  /// The mock CAPTCHA checkbox on the password creation screen.
  static const Key captchaCheckbox = Key('captcha_checkbox');

  /// The "Continue" button on the password creation screen.
  static const Key registerContinueButton = Key('register_continue_button');

  // ── TellUsMoreScreen ─────────────────────────────────────────────────────
  /// The display name [AppTextField] on the "Tell us more" screen.
  static const Key displayNameField = Key('display_name_field');

  /// The month [AuthDropdownField] on the "Tell us more" screen.
  static const Key dobMonthDropdown = Key('dob_month_dropdown');

  /// The day [AuthDropdownField] on the "Tell us more" screen.
  static const Key dobDayDropdown = Key('dob_day_dropdown');

  /// The year [AuthDropdownField] on the "Tell us more" screen.
  static const Key dobYearDropdown = Key('dob_year_dropdown');

  /// The gender [AuthDropdownField] on the "Tell us more" screen.
  static const Key genderDropdown = Key('gender_dropdown');

  /// The "Continue" button on the "Tell us more" screen.
  static const Key tellUsMoreContinueButton = Key(
    'tell_us_more_continue_button',
  );

  // ── VerifyEmailScreen ────────────────────────────────────────────────────
  /// The screen title text on the verify-email screen.
  /// Used to assert the screen appeared (e.g. after unverified login — M1-007).
  static const Key verifyEmailTitle = Key('verify_email_title');

  /// Token digit field at position [i] (0–5).
  /// Call [AuthKeys.tokenDigit] instead of constructing manually.
  static Key tokenDigitAt(int i) => Key('token_digit_$i');

  /// The "Verify" button on the verify-email screen.
  static const Key verifyButton = Key('verify_button');

  /// The "Didn't get an email? Resend" link on the verify-email screen.
  static const Key resendCodeButton = Key('resend_code_button');

  // ── PasswordScreen (login) ───────────────────────────────────────────────
  /// The password [AppTextField] on the sign-in password screen.
  static const Key loginPasswordField = Key('login_password_field');

  /// The "Continue" button on the sign-in password screen.
  static const Key loginContinueButton = Key('login_continue_button');

  /// The "Forgot your password?" link on the sign-in password screen.
  static const Key forgotPasswordLink = Key('forgot_password_link');

  // ── ForgotPasswordScreen ─────────────────────────────────────────────────
  /// The email [AppTextField] on the forgot-password screen.
  static const Key forgotPasswordEmailField = Key(
    'forgot_password_email_field',
  );

  /// The "Send reset link" button on the forgot-password screen.
  static const Key sendResetLinkButton = Key('send_reset_link_button');

  // ── ResetPasswordScreen ──────────────────────────────────────────────────
  /// The 6-character reset token [AppTextField] on the reset-password screen.
  static const Key resetTokenField = Key('reset_token_field');

  /// The new password [AppTextField] on the reset-password screen.
  static const Key resetNewPasswordField = Key('reset_new_password_field');

  /// The confirm password [AppTextField] on the reset-password screen.
  static const Key resetConfirmPasswordField = Key(
    'reset_confirm_password_field',
  );

  /// The "Save" / "Reset password" button on the reset-password screen.
  static const Key resetSaveButton = Key('reset_save_button');
}

// ── Finder helpers ────────────────────────────────────────────────────────────

/// Pre-built [Finder] instances for every auth-screen element.
///
/// These wrap [AuthKeys] so tests read naturally:
/// ```dart
/// await tester.tap(AuthFinders.continueOnEmailEntry);
/// expect(AuthFinders.verifyEmailTitle, findsOneWidget);
/// ```
abstract class AuthFinders {
  // ── SignInOrCreateScreen ─────────────────────────────────────────────────
  static final Finder signInEmailField = find.byKey(AuthKeys.signInEmailField);
  static final Finder signInContinueButton = find.byKey(
    AuthKeys.signInContinueButton,
  );

  // ── EmailEntryScreen ─────────────────────────────────────────────────────
  static final Finder emailEntryField = find.byKey(AuthKeys.emailEntryField);
  static final Finder emailEntryContinueButton = find.byKey(
    AuthKeys.emailEntryContinueButton,
  );

  // ── RegisterDetailScreen ─────────────────────────────────────────────────
  static final Finder registerPasswordField = find.byKey(
    AuthKeys.registerPasswordField,
  );
  static final Finder captchaCheckbox = find.byKey(AuthKeys.captchaCheckbox);
  static final Finder registerContinueButton = find.byKey(
    AuthKeys.registerContinueButton,
  );

  // ── TellUsMoreScreen ─────────────────────────────────────────────────────
  static final Finder displayNameField = find.byKey(AuthKeys.displayNameField);
  static final Finder dobMonthDropdown = find.byKey(AuthKeys.dobMonthDropdown);
  static final Finder dobDayDropdown = find.byKey(AuthKeys.dobDayDropdown);
  static final Finder dobYearDropdown = find.byKey(AuthKeys.dobYearDropdown);
  static final Finder genderDropdown = find.byKey(AuthKeys.genderDropdown);
  static final Finder tellUsMoreContinueButton = find.byKey(
    AuthKeys.tellUsMoreContinueButton,
  );

  // ── VerifyEmailScreen ────────────────────────────────────────────────────
  static final Finder verifyEmailTitle = find.byKey(AuthKeys.verifyEmailTitle);
  static Finder tokenDigitAt(int i) => find.byKey(AuthKeys.tokenDigitAt(i));
  static final Finder verifyButton = find.byKey(AuthKeys.verifyButton);
  static final Finder resendCodeButton = find.byKey(AuthKeys.resendCodeButton);

  // ── PasswordScreen ───────────────────────────────────────────────────────
  static final Finder loginPasswordField = find.byKey(
    AuthKeys.loginPasswordField,
  );
  static final Finder loginContinueButton = find.byKey(
    AuthKeys.loginContinueButton,
  );
  static final Finder forgotPasswordLink = find.byKey(
    AuthKeys.forgotPasswordLink,
  );

  // ── ForgotPasswordScreen ─────────────────────────────────────────────────
  static final Finder forgotPasswordEmailField = find.byKey(
    AuthKeys.forgotPasswordEmailField,
  );
  static final Finder sendResetLinkButton = find.byKey(
    AuthKeys.sendResetLinkButton,
  );

  // ── ResetPasswordScreen ──────────────────────────────────────────────────
  static final Finder resetTokenField = find.byKey(AuthKeys.resetTokenField);
  static final Finder resetNewPasswordField = find.byKey(
    AuthKeys.resetNewPasswordField,
  );
  static final Finder resetConfirmPasswordField = find.byKey(
    AuthKeys.resetConfirmPasswordField,
  );
  static final Finder resetSaveButton = find.byKey(AuthKeys.resetSaveButton);
}
